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

part of controller;

/**
 * The only controller of the application. Coordinates interactions between the domain model and views via view models.
 */
class AppController
{
  // TODO: doc
  List<String> _currentlyShownResults;

  Set<int> _currentlyShownResultsIndexFeedbackCollected = new Set();

  // TODO: doc
  String _lastCodeSentToModelForSynthesis;

  /**
   * A user interface for collecting search input and also indicating when a search is in progress.
   */
  final SearchView _searchView = new SearchView();

  /**
   * A user interface for displaying the results of a search and also initiating a new search.
   */
  final ResultsView _resultsView = new ResultsView.empty();

  /**
   * Takes user supplied search code and generates search results.
   */
  final Synthesiser _synthesiser;

  // TODO: doc
  final ResultQualityFeedbackRepository _qualityRepo;

  /**
   * Indicates if start() has been called.
   */
  bool _started = false;

  /**
   * Creates a controller that uses the given Synthesiser to generate search results from user supplied search code.
   * // TODO: doc
   */
  AppController(this._synthesiser, this._qualityRepo);

  /**
   * Shows the initial UI.  If an errorMessage is specified, will be shown to the user.  Calling start() more than once
   * has no effect.
   */
  void start([String errorMessage])
  {
    if(_started)
      return;

    /**
     * Respond to the search button being pressed in either view with the same handler.
     */
    _searchView.onSearchRequested.listen(_handleSearchRequested);
    _resultsView.onSearchRequested.listen(_handleSearchRequested);

    /**
     * Respond to a request for returning to the search view by returning to the search view.
     */
    _resultsView.onReturnToSearchViewRequested.listen( (_) { _handleReturnToSearchViewRequested(); });

    // TODO: doc
    _resultsView.onResultLikedSignaled.listen((int resultIndex){ _handleResultLiked(resultIndex); });
    _resultsView.onResultDislikedSignaled.listen((int resultIndex){ _handleResultDisliked(resultIndex); });

    _searchView.show();

    if(errorMessage != null)
      _showErrorMessage(errorMessage);

    _started = true;
  }

  /**
   * Switches to teh search view.
   */
  void _handleReturnToSearchViewRequested()
  {
    _resultsView.hide();
    _searchView.show();
  }

  // TODO: doc
  void _handleResultLiked(int resultIndex)
  {
    _handleResultFeedbackHelp(resultIndex, true);
  }

  // TODO: doc
  void _handleResultDisliked(int resultIndex)
  {
    _handleResultFeedbackHelp(resultIndex, false);
  }

  // TODO: doc
  void _handleResultFeedbackHelp(int resultIndex, bool isGood)
  {
    if(_lastCodeSentToModelForSynthesis == null || _currentlyShownResults == null)
      return; // bad state

    if(resultIndex < 0 || resultIndex >= _currentlyShownResults.length)
      return; // bad argument

    String result = _currentlyShownResults[resultIndex];

    _qualityRepo.addFeedback("3813b882-c84c-49cf-8d35-8b033c4aa908", _lastCodeSentToModelForSynthesis, result, isGood)
        .then((_) { _currentlyShownResultsIndexFeedbackCollected.add(resultIndex);  });
  }

  /**
   * Switches the view to search and shows the given error message.
   */
  void _showErrorMessage(String errorMessage)
  {
    _resultsView.hide();
    _searchView.setErrorMessage(errorMessage);
    _searchView.show();
    _searchView.hideSearchButton(); // error message placement overlaps with search button so hide in case visible.
    _searchView.hideSpinner(); // error message placement overlaps with spinner so hide in case visible.
  }

  /**
   * When user clicks on the search button from either view, switch to search view and start a search.
   */
  void _handleSearchRequested(String program)
  {
    _resultsView.hide();// we may be in results mode from a previous search, or, if first, already hidden so no effect.
    _searchView.show(); // we may already be in search mode if first search, but still ok, no effect.
    _searchView.hideSearchButton(); // we are doing a search now, so hide the search button until complete
    _searchView.showSpinner();      // we are doing a search now, so show the spinner until complete

    _lastCodeSentToModelForSynthesis = program;

    _synthesiser.synthesise(program)
        .then(_handleResultsAvailable)
        .catchError(_handleSynthesiseError);
  }

  /**
   * When search results become available, switch to results mode and show results.
   */
  void _handleResultsAvailable(List<String> results)
  {
    _searchView.hide(); // n.b. also hides the spinner started in _handleSearchRequested
    _resultsView.setViewModel(results);
    _resultsView.show(); // n.b. restores search button hidden in _handleSearchRequested
    _currentlyShownResults = results;

  }

  /**
   * When _synthesiser.synthesise(...) completes in error, show error message to user.
   */
  void _handleSynthesiseError(String errorMessage)
  {
    print(errorMessage);
    _showErrorMessage("Unexpected error. Please retry.");
  }
}