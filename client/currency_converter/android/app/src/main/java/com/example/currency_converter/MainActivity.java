package com.example.currency_converter;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import com.criticalblue.approovsdk.Approov;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintStream;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "com.criticalblue.approovsdk/approov";
  private static final String LOG_TAG = "EKKLOT-currency-converter";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("initApproov")) {
          approovInit();
          result.success(null);
        } else if (call.method.equals("fetchApproovToken")) {
          String token = fetchApproovTokenSynchronously();
          result.success(token);
        } else {
          result.notImplemented();
        }
      }
    });
  }

  private String fetchApproovTokenSynchronously() {
    Approov.TokenFetchResult pResult = Approov.fetchApproovTokenAndWait("my.domain.com");
    if (pResult.isConfigChanged())
      onConfigurationChanged(null);

    switch (pResult.getStatus()) {
    case SUCCESS:
    case NO_APPROOV_SERVICE:
      String approovToken = pResult.getToken();
      Log.i(LOG_TAG, "pass handling - getToken");
      return approovToken;
    case NO_NETWORK:
    case POOR_NETWORK:
    case MITM_DETECTED:
      // TODO: We should retry doing a fetch after a user driven event
      Log.i(LOG_TAG, "retry handling - getStatus [" + pResult.getStatus().toString() + "]");
      break;
    default:
      // TODO: There has been some error event that should be reported
      Log.i(LOG_TAG, "error handling - getStatus [" + pResult.getStatus().toString() + "]");
      break;
    }

    return null;
  }

  private void approovInit() {
    String initialConfig = null;
    Log.i(LOG_TAG, "Approov - initialConfig");
    try {
      InputStream stream = getAssets().open("approov_initial.config");
      BufferedReader reader = new BufferedReader(new InputStreamReader(stream, "UTF-8"));
      initialConfig = reader.readLine();
      reader.close();
    } catch (IOException e) {
      Log.e(LOG_TAG, "Approov - initial configuration read failed: " + e.getMessage());
      // fatal if the SDK cannot read an initial configuration
      throw new Error(e);
    }

    // read any dynamic configuration for the SDK from local storage
    String dynamicConfig = null;
    Log.i(LOG_TAG, "Approov - dynamicConfig");
    try {
      FileInputStream stream = getApplicationContext().openFileInput("approov-dynamic.config");
      BufferedReader reader = new BufferedReader(new InputStreamReader(stream, "UTF-8"));
      dynamicConfig = reader.readLine();
      reader.close();
    } catch (IOException e) {
      // we can log this but it is not fatal as the app will receive a new update if
      // the stored one is corrupted in some way
      Log.i(LOG_TAG, "Approov - dynamic configuration read failed: " + e.getMessage());
    }

    Log.i(LOG_TAG, "Approov - Approov.initialize");
    try {
      Approov.initialize(getApplicationContext(), initialConfig, dynamicConfig, null);
    } catch (IllegalArgumentException e) {
      Log.e(LOG_TAG, "Approov initialization failed: " + e.getMessage());
      // fatal if the SDK cannot be initialized as all subsequent attempts
      // to use the SDK will fail
      throw new Error(e);
    }

    // if we didn't have a dynamic configuration (after the first launch of the app)
    // then
    // we write it to local storage now
    if (dynamicConfig == null)
      saveApproovConfigUpdate();
  }

  /**
   * Saves an update to the Approov configuration to local configuration of the
   * app. This should be called after every Approov token fetch where
   * isConfigChanged() is set. It saves a new configuration received from the
   * Approov server to the local app storage so that it is available on app
   * startup on the next launch.
   */
  public void saveApproovConfigUpdate() {
    String updateConfig = Approov.fetchConfig();
    if (updateConfig == null)
      Log.e(LOG_TAG, "Approov - Could not get dynamic Approov configuration");
    else {
      try {
        FileOutputStream outputStream = getApplicationContext().openFileOutput("approov-dynamic.config",
            Context.MODE_PRIVATE);
        PrintStream printStream = new PrintStream(outputStream);
        printStream.print(updateConfig);
        printStream.close();
      } catch (IOException e) {
        // we can log this but it is not fatal as the app will receive a new update if
        // the
        // stored one is corrupted in some way
        Log.e(LOG_TAG, "Approov - Cannot write Approov dynamic configuration: " + e.getMessage());
        return;
      }
      Log.i(LOG_TAG, "Approov - Wrote dynamic Approov configuration");
    }
  }
}
