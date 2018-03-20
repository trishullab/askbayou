/*
 Copyright 2016 Rice University

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
var editorLeft = ace.edit("editor-left");
editorLeft.setTheme("ace/theme/github");
editorLeft.getSession().setMode("ace/mode/java");
editorLeft.setOption("showPrintMargin", false);
editorLeft.setOption("enableBasicAutocompletion", true);
var evidenceCompleter = {
    getCompletions: function(editor, session, pos, prefix, callback) {
        callback(null, apicalls.map(function(word) {
            return {
                name: word,
                value: "call:" + word,
                meta: "API call",
                score: -apicalls.indexOf(word)
            };
        }).concat(types.map(function(word) {
            return {
                name: word,
                value: "type:" + word,
                meta: "Type",
                score: -types.indexOf(word)
            };
        })).concat(keywords.map(function(word) {
            return {
                name: word,
                value: word,
                meta: "Keyword",
                score: -keywords.indexOf(word)
            };
        })));
    }
};
editorLeft.completers = [evidenceCompleter];

var editorRight = ace.edit("editor-right");
editorRight.setTheme("ace/theme/github");
editorRight.getSession().setMode("ace/mode/java");
editorRight.setOption("showPrintMargin", false);
editorRight.setReadOnly(true);

var Range = require("ace/range").Range;

/**
 * Gets the code content of the left editor.
 */
function getEditorLeftContent()
{
    return editorLeft.getValue();
}

/**
 * Sets the code content of the left editor.
 * @param content the content to show.
 */
function setEditorLeftContent(content)
{
    editorLeft.setValue(content);
    editorLeft.gotoLine(1, 0); // Without this ACE will highlight the entire content of the editor.
}

/**
 * Sets the code content of the right editor.
 * @param content the content to show.
 */
function setEditorRightContent(content)
{
    editorRight.setValue(content);
    editorRight.gotoLine(1, 0); // Without this ACE will highlight the entire content of the editor.
}

function registerLeftEditorChangeListener()
{
    editorLeft.on("change", detectTripleSlash);
}

function detectTripleSlash(e)
{
    // check if line has ///
    var currLine = editorLeft.getSelectionRange().start.row;
    var lineContent = editorLeft.session.getLine(currLine);
    if (lineContent.includes("///")) {
        editorLeft.setOption("enableLiveAutocompletion", true);
        editorLeft.session.replace(new Range(currLine, 0, currLine, Number.MAX_VALUE),
                lineContent.replace(/ [a-zA-Z0-9_:]+call:/, " call:").replace(/ [a-zA-Z0-9_:]+type:/, " type:"));
    }
    else
        editorLeft.setOption("enableLiveAutocompletion", false);
}