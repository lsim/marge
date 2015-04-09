define [], () ->
  DiffMatchPatch = require('googlediff')
  diff_match_patch = new DiffMatchPatch()
  diff_match_patch.Match_Threshold = 0.5

  diff = (file1, file2) -> diff_match_patch.diff_main(file1, file2)

  ###
    3-way merge pseudocode:
    patches = patch_make(V0, V2)
    (V3, result) = patch_apply(patches, V1)

    The result list is an array of true/false values.  If it's all true,
    then the merge worked great.  If there's a false, then one of the
    patches could not be applied.  In that case it might be worth swapping
    V1 and V2, trying again and seeing if the results are better.

  ###
  merge = (v0, v1, v2) ->
    patches = diff_match_patch.patch_make(v0, v2)
    [resultText, status] = diff_match_patch.patch_apply(patches, v1)
    console.debug "merge status", status
    # return
    [resultText, status]

  generateFutureHighlights = (base, future) ->
    differences = diff(base, future)
    sideId = 1
    # Get rid of the differences that are brought about by the other side of the merge
    differences = _.filter(differences, (difference) -> difference[0] is 0 or difference[0] is sideId)

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

  generateBaseHighlights = (base, future1, future2) ->
    []

  threeWayMerge: (base, future1, future2) ->
    [resultText, status] = merge(base, future1, future2)

    # return
    base:
      text: base
      highlights: generateBaseHighlights(base, future1, future2)
    future1:
      text: future1
      highlights: generateFutureHighlights(base, future1)
    future2:
      text: future2
      highlights: generateFutureHighlights(base, future2)
    result:
      text: resultText
      highlights: []
      statusText: "(individual patch status: #{status.join(",")})"

