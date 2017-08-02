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

class SearchView
{
  final HtmlElement _searchButton = querySelector("#search-button");

  final HtmlElement _searchSpinner = querySelector("#search-spinner");

  final HtmlElement _editorLeft = querySelector("#editor-left");

  final HtmlElement _editorRight = querySelector("#editor-right");

  final HtmlElement _errorMessage = querySelector("#error-message");

  final SelectElement _sourceSelect = querySelector("#source-select");

  final Element _infoBox = querySelector("#info-box");

  final Map<String,String> _filenameToContent =
  {
    "Bluetooth" :
    """
import edu.rice.cs.caper.bayou.annotations.Evidence;
import android.bluetooth.BluetoothAdapter;

// Bayou supports three types of evidence:
// 1. apicalls - API methods the code should invoke
// 2. types - datatypes of objects which invoke API methods
// 3. context - datatypes of variables that the code should use

public class TestBluetooth {

    /* Get an input stream that can be used to read from
     * the given blueooth hardware address */
    void readFromBluetooth(BluetoothAdapter adapter) {
        // Intersperse code with evidence
        String address = "00:43:A8:23:10:F0";

        { // Provide evidence within a separate block
            // Code should call "getInputStream"...
            Evidence.apicalls("getInputStream");
            // ...on a "BluetoothSocket" type
            Evidence.types("BluetoothSocket");
        } // Synthesized code will replace this block
    }

}
""",
    "Camera":
"""
import edu.rice.cs.caper.bayou.annotations.Evidence;

// Bayou supports three types of evidence:
// 1. apicalls - API methods the code should invoke
// 2. types - datatypes of objects which invoke API methods
// 3. context - datatypes of variables that the code should use

public class TestCamera {

    /* Start a preview of the camera, by setting the
     * preview's width and height using the given ints */
    void preview() {
        // Intersperse code with evidence
        int width = 640;
        int height = 480;

        { // Provide evidence within a separate block
            // Code should call "startPreview"...
            Evidence.apicalls("startPreview");
            // ...and use an "int" as argument
            Evidence.context("int");
        } // Synthesized code will replace this block
    }

}
""",
    "Dialog":
"""
import edu.rice.cs.caper.bayou.annotations.Evidence;
import android.content.Context;

// Bayou supports three types of evidence:
// 1. apicalls - API methods the code should invoke
// 2. types - datatypes of objects which invoke API methods
// 3. context - datatypes of variables that the code should use

public class TestDialog {

    /* Create an alert dialog with the given strings
     * as content (title and message) in the dialog */
    void createDialog(Context c) {
        // Intersperse code with evidence
        String str1 = "something here";
        String str2 = "another thing here";

        { // Provide evidence within a separate block
            // Code should call "setTitle" and "setMessage"...
            Evidence.apicalls("setTitle", "setMessage");
            // ...on an "AlertDialog" type
            Evidence.types("AlertDialog");
        } // Synthesized code will replace this block
    }

}
""",
    "IO":
"""
import edu.rice.cs.caper.bayou.annotations.Evidence;

// Bayou supports three types of evidence:
// 1. apicalls - API methods the code should invoke
// 2. types - datatypes of objects which invoke API methods
// 3. context - datatypes of variables that the code should use

public class TestIO {

    // NOTE: Bayou only supports one synthesis task in a given
    // program at a time, so please comment out the rest.

    /* Read from a file */
    void read(String file) {
        { // Provide evidence within a separate block
            // Code should call "readLine"
            Evidence.apicalls("readLine");
        } // Synthesized code will replace this block
    }

    /*
    // Read from a file, more specifically using the
    // string argument given
    void read(String file) {
        {
            Evidence.apicalls("readLine");
            Evidence.context("String");
        }
    }
    */

    /*
    // Read from the file, performing exception handling
    // properly by printing the stack trace
    void readWithErrorHandling() {
        String file;
        {
            Evidence.apicalls("readLine", "printStackTrace", "close");
            Evidence.context("String");
        }
    }
    */
}
""",
    "Speech":
    """
import edu.rice.cs.caper.bayou.annotations.Evidence;
import android.content.Context;
import android.content.Intent;
import android.speech.RecognitionListener;

// Bayou supports three types of evidence:
// 1. apicalls - API methods the code should invoke
// 2. types - datatypes of objects which invoke API methods
// 3. context - datatypes of variables that the code should use

public class TestSpeech {

    /* Construct a speech regonizer with the provided listener */
    void speechRecognition(Context context, Intent intent, RecognitionListener listener) {
        { // Provide evidence within a separate block
            // Code should make API calls on "SpeechRecognizer"...
            Evidence.types("SpeechRecognizer");
            // ...and use a "Context" as argument
            Evidence.context("Context");
        } // Synthesized code will replace this block
    }

}
""",
    "Wifi":
    """
import edu.rice.cs.caper.bayou.annotations.Evidence;
import android.net.wifi.WifiManager;

// Bayou supports three types of evidence:
// 1. apicalls - API methods the code should invoke
// 2. types - datatypes of objects which invoke API methods
// 3. context - datatypes of variables that the code should use

public class TestWifi {

    /* Start a wi-fi scan using the given manager */
    void scan(WifiManager manager) {
        { // Provide evidence within a separate block
            // Code should call "startScan"...
            Evidence.apicalls("startScan");
            // ...on a "WifiManager" type
            Evidence.types("WifiManager");
        } // Synthesized code will replace this block

    }

}
"""

  };

  /**
   * Controller for onSearchRequested
   */
  StreamController<String> _onSearchRequestedController = new StreamController(sync: true);

  /**
   * Fired to signal the user has requested a search of the provided code.
   */
  Stream<String> get onSearchRequested => _onSearchRequestedController.stream;

  /**
   * Indicates if the view is in the shown vs hidden state.  See show() and hide().
   */
  bool _isShown = false;

  /**
   * Creates a new search view. Does not update DOM until show() or hide() is called.
   */
  SearchView()
  {
    _searchButton.onClick.listen((_) { _handleSearchButtonClicked(); });
    _sourceSelect.onChange.listen((_) { _handleSourceSelectChanged(); } );
    _populateLeftEditorFromSourceSelect();
  }

  /**
   * Hides the search button.
   */
  void hideSearchButton()
  {
    _searchButton.style.display = "none";
  }

  /**
   * Shows the searching spinner.
   */
  void showSpinner()
  {
    _searchSpinner.style.display = "block";
  }

  /**
   * Hides the searching spinner.
   */
  void hideSpinner()
  {
    _searchSpinner.style.display = "none";
  }

  /**
   * Shows all the UI elements of the view except the spinner.
   */
  void show()
  {
    _editorLeft.style.display = "block";
    _editorRight.style.display = "block";
    //_editorLeft.style.width = "100%";
    _searchButton.style.display = 'block';
    _errorMessage.style.display = "inline";
    _sourceSelect.style.display = "block";
    _isShown = true;
  }

  /**
   * Hides all the UI elements of the view.
   */
  void hide()
  {
    hideSpinner();
    _editorLeft.style.display = "none";
    _searchButton.style.display = 'none';
    _errorMessage.style.display = "none";
    _searchSpinner.style.display = "none";
    _sourceSelect.style.display = "none";
    _isShown = false;
  }

  /**
   * If in the shown state, fires onSearchRequested passing the contents of the left editor.
   */
  void _handleSearchButtonClicked()
  {
    if(!_isShown) // needed because both views use the same search button and as such both will get the click event.
      return;

    _infoBox.style.display = "none"; // hide info box since it covers the area where results are shown.

    String editorContent = getEditorLeftContent();
    _onSearchRequestedController.add(editorContent);
  }


  /**
   * Set the left editor content based on what drop down source file was selected by the user.
   */
  void _handleSourceSelectChanged()
  {
    _populateLeftEditorFromSourceSelect();
  }

  void _populateLeftEditorFromSourceSelect()
  {
    if(_sourceSelect.value == null)
      return;

    if(_filenameToContent.containsKey(_sourceSelect.value))
    {
      String source = _filenameToContent[_sourceSelect.value];
      setEditorLeftContent(source);
    }
  }

  /**
   * Sets the content of the error message UI element. Does not alter its display status. (So may be hidden even after
   * this method is called.)
   */
  void setErrorMessage(String errorMessage)
  {
    setEditorRightContent(errorMessage);
  }
}

/**
 * Sets the code contents of the left ace editor.
 */
@JS()
external setEditorLeftContent(String content);
