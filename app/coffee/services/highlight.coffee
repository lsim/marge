define ['app', '_'], (app, _) ->

  app.factory 'highlightsvc', ->

    # Invoke with an array of differences obtained from diff-match-patch and the id of the side of the diff to highlight for
    (differences, sideId) ->

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
