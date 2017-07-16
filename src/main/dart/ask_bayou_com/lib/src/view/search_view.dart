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

  final Map<String,String> _filenameToContent =
  {
    "Bluetooth" :
    """
import edu.rice.cs.caper.bayou.annotations.Evidence;
import android.bluetooth.BluetoothAdapter;

public class TestBluetooth {

    /* Get an input stream that can be used to read from
     * the given blueooth hardware address */
    void readFromBluetooth(BluetoothAdapter adapter) {
        String address = "00:43:A8:23:10:F0";
        {
            Evidence.apicalls("getInputStream");
            Evidence.types("BluetoothSocket");
        }
    }   

}
""",
    "Camera":
"""
import edu.rice.cs.caper.bayou.annotations.Evidence;

public class TestCamera {

    /* Start a preview of the camera, by setting the
     * preview's width and height using the given ints */
    void preview() {
        int width = 640;
        int height = 480;
        {
            Evidence.apicalls("startPreview");
            Evidence.context("int");
        }
    }   

}
""",
    "Dialog":
"""
import edu.rice.cs.caper.bayou.annotations.Evidence;
import android.content.Context;

public class TestDialog {

    /* Create an alert dialog with the given strings
     * as content (title and message) in the dialog */
    void createDialog(Context c) {
        String str1 = "something here";
        String str2 = "another thing here";
        {
            Evidence.apicalls("setTitle", "setMessage");
            Evidence.types("AlertDialog");
        }
    }   

}
""",
    "IO1":
"""
import edu.rice.cs.caper.bayou.annotations.Evidence;

public class TestIO1 {

    // Read from a file
    void read(String file) {
        Evidence.apicalls("readLine");
    }   
}

""",
    "IO2":
"""
import edu.rice.cs.caper.bayou.annotations.Evidence;

public class TestIO2 {

    // Read from a file, more specifically using the
    // string argument given
    void read(String file) {
        Evidence.apicalls("readLine");
        Evidence.context("String");
    }   
}

""",
    "IO_exception":
"""
import edu.rice.cs.caper.bayou.annotations.Evidence;

public class TestIOException {

    // Read from the file, performing exception handling
    // properly by printing the stack trace
    void readWithErrorHandling() {
        String file;
        {
            Evidence.apicalls("readLine", "printStackTrace", "close");
            Evidence.context("String");
        }
    }   
}
""",
    "Speech":
    """
import edu.rice.cs.caper.bayou.annotations.Evidence;
import android.content.Context;
import android.content.Intent;
import android.speech.RecognitionListener;

public class TestSpeech {

    /* Construct a speech regonizer with the provided listener */
    void speechRecognition(Context context, Intent intent, RecognitionListener listener) {
        {
            Evidence.types("SpeechRecognizer");
            Evidence.context("Context");
        }
    }   

}
""",
    "Wifi":
    """
import edu.rice.cs.caper.bayou.annotations.Evidence;
import android.net.wifi.WifiManager;

public class TestWifi {

    /* Start a wi-fi scan using the given manager */
    void scan(WifiManager manager) {
        {
            Evidence.apicalls("startScan");
            Evidence.types("WifiManager");
        }
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
    _errorMessage.innerHtml = errorMessage;
  }
}

/**
 * Sets the code contents of the left ace editor.
 */
@JS()
external setEditorLeftContent(String content);
