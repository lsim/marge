define [], () ->
  DiffMatchPatch = require('googlediff')
  diff_match_patch = new DiffMatchPatch()
  diff_match_patch.Match_Threshold = 0.1

  characterLevelDiff = (file1, file2) ->
    res = diff_match_patch.diff_main(file1, file2)
    diff_match_patch.diff_cleanupSemantic(res)
    # return
    res

  lineLevelDiff = (file1, file2) ->
    {chars1, chars2, lineArray} = diff_match_patch.diff_linesToChars_(file1, file2)
    diffs = diff_match_patch.diff_main(chars1, chars2, false)
    diff_match_patch.diff_charsToLines_(diffs, lineArray)
    diff_match_patch.diff_cleanupSemantic(diffs)
    # return
    diffs

  ###
  function diff_lineMode(text1, text2) {
    var dmp = new diff_match_patch();
    var a = dmp.diff_linesToChars_(text1, text2);
    var lineText1 = a[0];
    var lineText2 = a[1];
    var lineArray = a[2];

    var diffs = dmp.diff_main(lineText1, lineText2, false);

    dmp.diff_charsToLines_(diffs, lineArray);
    return diffs;
  }
  ###

  ###
    3-way merge pseudocode:
    patches = patch_make(V0, V2)
    (V3, result) = patch_apply(patches, V1)

    The result list is an array of true/false values.  If it's all true,
    then the merge worked great.  If there's a false, then one of the
    patches could not be applied.  In that case it might be worth swapping
    V1 and V2, trying again and seeing if the results are better.

  ###
  merge = (base, future1, future2diff) ->
    patches = diff_match_patch.patch_make(base, future2diff)
    [resultText, status] = diff_match_patch.patch_apply(patches, future1)
    console.debug "merge status", status
    # return
    [resultText, status]

  createHighlightPatches = (base, differences) ->
    patches = diff_match_patch.patch_make(base, differences)
#    lines = {text, i} for text, i in future.split('\n')

    # enrich each patch with line and column offsets for highlighting
    # do this by counting line breaks up until the patch start index
    _.each(patches, (patch) ->
      patch.startLineIndex = (base.substring(0, patch.start1).match(/\n/g) || []).length
      changeType = ''
      rowCountDelta = 0
      if patch.diffs.length is 4 # delete + add = replacement
        changeType = 'replace'
      else if patch.diffs.length is 3 # delete or add
        changeType = if patch.diffs[1][0] is -1 then 'delete' else 'add'
    )

  mapLineDiffsToChunks = (differences) ->
    lineCounter = 0
    # return
    _.map differences, ([typeInt,text]) ->
      chunk =
        type: switch typeInt
          when 1 then 'add'
          when -1 then 'delete'
          else 'nop'
        text: if typeInt is -1 then text.replace(/[^\s]/g, ' ') else text
      numChunkLines = (chunk.text.match(/\n/g) || []).length
      chunk.lineStart = lineCounter
      chunk.lineEnd = lineCounter + numChunkLines
      lineCounter += numChunkLines
      # return
      chunk


  mapDiffsToChunks = (differences) ->
    lineCounter = 0
    colsSinceLastBreak = 0
    # return
    _.map differences, ([typeInt,text]) ->
      chunk =
        type: switch typeInt
          when 1 then 'add'
          when -1 then 'delete'
          else 'nop'
        text: if typeInt is -1 then text.replace(/[^\s]/g, ' ') else text
      numChunkLines = (chunk.text.match(/\n/g) || []).length
      chunk.lineStart = lineCounter
      chunk.lineEnd = lineCounter + numChunkLines
      chunk.colStart = colsSinceLastBreak
      lastBreakIndex = chunk.text.lastIndexOf('\n') # TODO: handle other newline types
      colsSinceLastBreak = if lastBreakIndex > -1
        chunk.text.length - lastBreakIndex - 1
      else
        colsSinceLastBreak + chunk.text.length
      chunk.colEnd = colsSinceLastBreak
      lineCounter += numChunkLines
      # return
      chunk

  generateFutureHighlights = (base, future) ->
    differences = characterLevelDiff(base, future)

    # Get rid of the differences that are brought about by the other side of the merge
    differences = _.filter(differences, (difference) -> difference[0] is 0 or difference[0] is 1)

    # Collapse sequences of matching regions into just one
    index = 0
    sections = while index < differences.length
      value = differences[index][0]
      aSlice = _.takeWhile(_.drop(differences, index), (d) -> d[0] == value)
      index += aSlice.length
      # return
      type: if value is 0 then 'unmarked' else 'marked'
      text: _.map(aSlice, (difference) -> difference[1]).join('')

    # Compute line- and col start/end
    lineCounter = 0
    colsSinceLastBreak = 0
    _.each(sections,
      (section) ->
        sectionLines = (section.text.match(/\n/g) || []).length
        section.lineStart = lineCounter
        section.lineEnd = lineCounter + sectionLines
        section.colStart = colsSinceLastBreak
        lastBreakIndex = section.text.lastIndexOf('\n') # TODO: handle other newline types
        colsSinceLastBreak = if lastBreakIndex > -1
          section.text.length - lastBreakIndex - 1
        else
          colsSinceLastBreak + section.text.length
        section.colEnd = colsSinceLastBreak
        lineCounter += sectionLines
    )

    # return just the highlighted/marked regions
    _.filter(sections, (section) -> section.type is 'marked')

  generateBaseHighlights = (base, future1, future2) -> []

  threeWayMerge: (base, future1, future2) ->
    future1Diffs = lineLevelDiff(base, future1)
    future2Diffs = lineLevelDiff(base, future2)
    [resultText, status] = merge(base, future1, future2Diffs)
    resultDiffs = lineLevelDiff(base, resultText)
    future1Patches = diff_match_patch.patch_make(base, future1Diffs)
    future2Patches = diff_match_patch.patch_make(base, future2Diffs)
    resultPatches = diff_match_patch.patch_make(base, resultDiffs)

#    future1LineDiff = lineLevelDiff(base, future1)

    # return
    base:
      highlights: generateBaseHighlights(base, future1, future2)
    future1:
#      highlights: generateFutureHighlights(base, future1)
      chunks: mapDiffsToChunks(future1Diffs)
    future2:
#      highlights: generateFutureHighlights(base, future2)
      chunks: mapDiffsToChunks(future2Diffs)
    result:
      text: resultText
      highlights: []
      statusText: "(individual patch status: #{status.join(",")})"

