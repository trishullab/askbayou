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

  final HtmlElement _errorMessage = querySelector("#error-message");

  final SelectElement _sourceSelect = querySelector("#source-select");

  final Map<String,String> _filenameToContent =
  {
    "TestBluetooth.java" :
    """
import edu.rice.bayou.annotations.Evidence;
import android.bluetooth.BluetoothAdapter;

public class TestBluetooth {

    @Evidence(apicalls = {"getInputStream"})
    @Evidence(types = {"BluetoothSocket"})
    void __bayou_fill(BluetoothAdapter adapter, String address) {

    }

}
""",
    "TestCamera.java":
"""
import edu.rice.bayou.annotations.Evidence;

public class TestCamera {

    @Evidence(apicalls = {"startPreview"})
    @Evidence(types = {"Camera"})
    void __bayou_fill(int w, int h) {

    }

}
""",
    "TestDialog.java":
    """
import edu.rice.bayou.annotations.Evidence;
import android.content.Context;

public class TestDialog {

    @Evidence(apicalls = {"setTitle", "setMessage"})
    @Evidence(types = {"AlertDialog"})
    void __bayou_fill(Context c, String str1, String str2) {

    }

}
""",
    "TestIO1.java":
    """
import edu.rice.bayou.annotations.Evidence;

public class TestIO1 {

    @Evidence(apicalls = {"readLine", "ready"})
    void __bayou_fill(String file) {

    }

}""",
    "TestIO2.java":
    """
import edu.rice.bayou.annotations.Evidence;
import java.io.InputStreamReader;

public class TestIO2 {

    @Evidence(types = {"BufferedReader"})
    @Evidence(context = {"Reader"})
    void __bayou_fill(InputStreamReader input) {

    }

}
""",
    "TestIO_exception.java":
    """
import edu.rice.bayou.annotations.Evidence;

public class TestIO_exception {

    @Evidence(apicalls = {"readLine", "printStackTrace", "close"})
    @Evidence(context = {"String"})
    void __bayou_fill(String file) {

    }

}""",
    "TestSpeech.java":
    """
import edu.rice.bayou.annotations.Evidence;
import android.content.Context;

public class TestSpeech {

    @Evidence(types = {"SpeechRecognizer"})
    @Evidence(context = {"Context"})
    void __bayou_fill(Context context) {

    }

}""",
    "TestWifi.java":
    """
import edu.rice.bayou.annotations.Evidence;
import android.net.wifi.WifiManager;

public class TestWifi {

    @Evidence(apicalls = {"startScan"})
    @Evidence(types = {"WifiManager"})
    void __bayou_fill(WifiManager manager) {

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
    _editorLeft.style.width = "100%";
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
