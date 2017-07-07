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
part of view;

/**
 * Show a list of results to the user.
 */
class ResultsView
{
  /**
   * The results to show to the user.
   */
  Iterable<String> _vm;

  final Set<int> _feedbackCollectedIndexes = new Set();

  final HtmlElement _searchButton = querySelector("#search-button");

  final HtmlElement _resultPrevButton = querySelector("#result-left-button");

  final HtmlElement _resultNextButton = querySelector("#result-right-button");

  final HtmlElement _editorLeft = querySelector("#editor-left");

  final HtmlElement _editorRight = querySelector("#editor-right");

  final HtmlElement _title = querySelector("#title");

  final HtmlElement _likeResultButton = querySelector("#like-button");

  final HtmlElement _dislikeResultButton = querySelector("#dislike-button");

  /**
   * An event fired to indicate the user has requested the results view to be closed a the search view restored.
   */
  Stream get onReturnToSearchViewRequested => _onReturnToSearchViewRequestedController.stream;

  /**
   * Controller for [onReturnToSearchViewRequested].
   */
  StreamController _onReturnToSearchViewRequestedController = new StreamController(sync: true);

  /**
   * A label to update with the unique number of the currently shown result.
   */
  final HtmlElement _resultNumber = querySelector("#result-number");

  /**
   * Container of _resultPrevButton, _resultNextButton, and _resultNumber.
   */
  final HtmlElement _resultsSelector = querySelector("#results-selector");

  /**
   * Controller for onSearchRequested
   */
  StreamController<String> _onSearchRequestedController = new StreamController(sync: true);

  /**
   * Fired to signal the user has requested a search of the provided code.
   */
  Stream<String> get onSearchRequested => _onSearchRequestedController.stream;

  StreamController<int> _onResultLikedSignaledController = new StreamController(sync: true);

  Stream<int> get onResultLikedSignaled => _onResultLikedSignaledController.stream;

  StreamController<int> _onResultDislikedSignaledController = new StreamController(sync: true);

  Stream<int> get onResultDislikedSignaled => _onResultDislikedSignaledController.stream;

  /**
   * The index of the currently shown result in _vm.  Null if there is no result to show.
   */
  int _resultIndex;

  /**
   * Indicates if the view is in the shown vs hidden state.  See show() and hide().
   */
  bool _isShown = false;

  /**
   * Creates a new view showing the user the given results. Given ResultsViewModel may not be null.
   * Does not update DOM until show() or hide() is called.
   */
  ResultsView(this._vm)
  {
    if(this._vm == null)
      throw new ArgumentError.notNull("this.vm");

    _resultPrevButton.onClick.listen((_) { _handleShowPrevResult();  });
    _resultNextButton.onClick.listen((_) { _handleShowNextResult();  });
    _searchButton.onClick.listen((_) { _handleSearchButtonClicked(); });
    _title.onClick.listen((_) { _handleTitleClicked(); } );
    _likeResultButton.onClick.listen((_) { _handleLikeResultButtonClicked(); } );
    _dislikeResultButton.onClick.listen((_) { _handleDislikeResultButtonClicked(); } );
  }

  /**
   * If in the shown state, fires the onReturnToSearchViewRequested event.
   */
  void _handleTitleClicked()
  {
    if(_isShown) // needed because both views use the same title HTML and as such both will get the click event.
      _onReturnToSearchViewRequestedController.add(null);
  }

  // TODO: doc
  void _handleLikeResultButtonClicked()
  {
    _handleResultButtonClickedHelp(_onResultLikedSignaledController);
  }

  // TODO: doc
  void _handleDislikeResultButtonClicked()
  {
    _handleResultButtonClickedHelp(_onResultDislikedSignaledController);
  }

  // TODO: doc
  void _handleResultButtonClickedHelp(StreamController<int> eventController)
  {
    if(!_isShown) // should only be visible to be clicked when isShown is true, but let's be paranoid.
      return;

    _feedbackCollectedIndexes.add(_resultIndex);
    eventController.add(_resultIndex);
    _showOrHideFeedbackButtons();
  }

  /**
   * Creates a new view shownig no results. Does not update DOM until show() or hide() is called.
   */
  ResultsView.empty() : this([]);

  /**
   * If in the shown state, fires onSearchRequested passing the contents of the left editor.
   */
  void _handleSearchButtonClicked()
  {
    if(!_isShown) // needed because both views use the same search button and as such both will get the click event.
      return;

    _onSearchRequestedController.add(getEditorLeftContent());
  }

  /**
   * Show the previous result in _vm with respect to the currently displayed result wrapping to the end if
   * needed.
   */
  void _handleShowPrevResult()
  {
    _resultIndex = (_resultIndex - 1) % _vm.length;
    setEditorRightContent(_vm.toList()[_resultIndex]);
    _resultNumber.innerHtml = (_resultIndex + 1).toString();
    _showOrHideFeedbackButtons();
  }

  /**
   * Show the next result in _vm with respect to the currently displayed result wrapping to the front if needed.
   */
  void _handleShowNextResult()
  {
    _resultIndex = (_resultIndex + 1) % _vm.length;
    setEditorRightContent(_vm.toList()[_resultIndex]);
    _resultNumber.innerHtml = (_resultIndex + 1).toString();
    _showOrHideFeedbackButtons();
  }

  /**
   * Show all the UI elements of the view, except _resultsSelector in the case where the number of results is less
   * than 2.
   */
  void show()
  {
    _searchButton.style.display = "block";
    _editorLeft.style.display = "block";
    _editorRight.style.display = "block";
    _editorLeft.style.width = "50%";
    _editorRight.style.width = "50%";

    if(_vm.toList().length >=2)
      _resultsSelector.style.display = "block";

    _showOrHideFeedbackButtons();

    _isShown = true;
  }

  // todo: doc
  void _showOrHideFeedbackButtons()
  {
    bool shouldBeShown = !_vm.isEmpty && !_feedbackCollectedIndexes.contains(_resultIndex);

    if(shouldBeShown)
    {
      _likeResultButton.style.display = "block";
      _dislikeResultButton.style.display = "block";
    }
    else
    {
      _likeResultButton.style.display = "none";
      _dislikeResultButton.style.display = "none";
    }

  }

  /**
   * Hides all the UI elements of the view.
   */
  void hide()
  {
    _searchButton.style.display = "none";
    _editorLeft.style.display = "none";
    _editorRight.style.display = "none";
    _resultsSelector.style.display = "none";
    _likeResultButton.style.display = "none";
    _dislikeResultButton.style.display = "none";
    _isShown = false;
  }

  /**
   * Updates the view to reflect the given results.
   */
  void setViewModel(Iterable<String> vm)
  {
    _vm = vm;
    _feedbackCollectedIndexes.clear();
    _showOrHideFeedbackButtons();

    if(_vm.isEmpty)
    {
      _resultIndex = null;
      setEditorRightContent("");
      _resultsSelector.style.display = "none"; // n.b. safe to do no matter what _isShown state is
    }
    else
    {
      _resultIndex = 0;
      setEditorRightContent(_vm.first);
      _resultNumber.innerHtml = "1"; // n.b. wrapped by _resultsSelector so may or may not be shown

      if(_vm.length == 1) // no need to select among a single result
        _resultsSelector.style.display = "none"; // n.b. safe to do no matter what _isShown state is

      if(_vm.length >= 2 && _isShown == true) // we could call this method while hidden so check _isShown
        _resultsSelector.style.display = "block";     // before making anything visible
    }
  }
}

/**
 * Sets the code contents of the right ace editor.
 */
@JS()
external setEditorRightContent(String content);
