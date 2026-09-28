/*
 * Copyright 2026 The YiuOS Project
 * SPDX-License-Identifier: Apache-2.0
 */
package org.yiuos.home;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.provider.MediaStore;
import android.provider.Settings;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.GridLayout;
import android.widget.LinearLayout;
import android.widget.Space;
import android.widget.TextView;
import android.widget.Toast;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * A deliberately small launcher for the first hinoki bring-up.
 *
 * It implements the prototype's home surface without depending on APIs newer
 * than Android 8.1. System applications remain the proven LineageOS apps; the
 * launcher opens them through stable platform intents.
 */
public final class HomeActivity extends Activity {
    private static final int ORANGE = Color.rgb(255, 106, 0);
    private static final int INK = Color.rgb(39, 30, 26);
    private static final int MUTED = Color.rgb(117, 102, 94);

    private final Handler mHandler = new Handler();
    private FrameLayout mRoot;
    private TextView mClock;

    private final Runnable mClockTick = new Runnable() {
        @Override
        public void run() {
            updateClock();
            mHandler.postDelayed(this, 30_000L);
        }
    };

    @Override
    protected void onCreate(Bundle state) {
        super.onCreate(state);

        Window window = getWindow();
        window.setStatusBarColor(Color.TRANSPARENT);
        window.setNavigationBarColor(Color.rgb(31, 24, 21));
        window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
        window.getDecorView().setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                        | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);

        showHome();
    }

    @Override
    protected void onResume() {
        super.onResume();
        mHandler.removeCallbacks(mClockTick);
        mClockTick.run();
    }

    @Override
    protected void onPause() {
        mHandler.removeCallbacks(mClockTick);
        super.onPause();
    }

    private void showHome() {
        mRoot = new FrameLayout(this);
        mRoot.setBackground(gradient(
                new int[] {
                        Color.rgb(255, 246, 238),
                        Color.rgb(250, 230, 210),
                        Color.rgb(255, 172, 101)
                },
                GradientDrawable.Orientation.TL_BR,
                0));
        setContentView(mRoot);

        LinearLayout page = new LinearLayout(this);
        page.setOrientation(LinearLayout.VERTICAL);
        page.setPadding(dp(20), dp(34), dp(20), dp(18));
        mRoot.addView(page, match());

        LinearLayout status = row();
        mClock = text("12:38", 14, Typeface.BOLD, INK);
        status.addView(mClock);
        Space statusGap = new Space(this);
        status.addView(statusGap, new LinearLayout.LayoutParams(0, 1, 1));
        status.addView(text("⌁  LTE  82%", 12, Typeface.BOLD, INK));
        page.addView(status, widthMatchHeightWrap());

        Button ready = pill(getString(R.string.ready), ORANGE, Color.WHITE);
        LinearLayout.LayoutParams readyParams = widthWrapHeightWrap();
        readyParams.gravity = Gravity.CENTER_HORIZONTAL;
        readyParams.topMargin = dp(20);
        ready.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showControlCenter();
            }
        });
        page.addView(ready, readyParams);

        LinearLayout.LayoutParams heroGap = new LinearLayout.LayoutParams(1, 0, 0.6f);
        page.addView(new Space(this), heroGap);

        TextView greeting = text("Good morning", 15, Typeface.NORMAL, MUTED);
        page.addView(greeting);
        TextView title = text("Your space,\nyour rules.", 36, Typeface.BOLD, INK);
        title.setLineSpacing(0, 0.95f);
        page.addView(title);

        LinearLayout cards = row();
        cards.setPadding(0, dp(18), 0, 0);
        LinearLayout weather = card();
        weather.addView(text("KOZANI", 11, Typeface.BOLD, MUTED));
        weather.addView(text("29°  ☀", 28, Typeface.BOLD, INK));
        weather.addView(text("Clear · feels like 28°", 11, Typeface.NORMAL, MUTED));
        cards.addView(weather, weightedCard());

        LinearLayout date = card();
        date.addView(text(
                new SimpleDateFormat("EEE", Locale.getDefault())
                        .format(new Date()).toUpperCase(Locale.getDefault()),
                11, Typeface.BOLD, ORANGE));
        date.addView(text(
                new SimpleDateFormat("d", Locale.getDefault()).format(new Date()),
                28, Typeface.BOLD, INK));
        date.addView(text("No events today", 11, Typeface.NORMAL, MUTED));
        LinearLayout.LayoutParams dateParams = weightedCard();
        dateParams.leftMargin = dp(10);
        cards.addView(date, dateParams);
        page.addView(cards);

        GridLayout apps = new GridLayout(this);
        apps.setColumnCount(4);
        apps.setPadding(0, dp(22), 0, dp(12));
        addApp(apps, "☎", "Phone", new Intent(Intent.ACTION_DIAL));
        addApp(apps, "●", "Messages", categoryIntent(Intent.CATEGORY_APP_MESSAGING));
        addApp(apps, "◉", "Camera", new Intent(MediaStore.INTENT_ACTION_STILL_IMAGE_CAMERA));
        addApp(apps, "✿", "Gallery", typedIntent(Intent.ACTION_VIEW, "image/*"));
        addApp(apps, "⌁", "Files", typedIntent(Intent.ACTION_OPEN_DOCUMENT, "*/*"));
        addApp(apps, "⌾", "Browser", new Intent(Intent.ACTION_VIEW, Uri.parse("https://duckduckgo.com")));
        addApp(apps, "✓", "Privacy", new Intent(Settings.ACTION_PRIVACY_SETTINGS));
        addApp(apps, "⚙", "Settings", new Intent(Settings.ACTION_SETTINGS));
        page.addView(apps, widthMatchHeightWrap());

        LinearLayout dock = row();
        dock.setGravity(Gravity.CENTER);
        dock.setPadding(dp(8), dp(9), dp(8), dp(9));
        dock.setBackground(roundRect(Color.argb(218, 255, 255, 255), dp(24)));
        addDock(dock, "☎", new Intent(Intent.ACTION_DIAL));
        addDock(dock, "●", categoryIntent(Intent.CATEGORY_APP_MESSAGING));
        addDock(dock, "⌾", new Intent(Intent.ACTION_VIEW, Uri.parse("https://duckduckgo.com")));
        addDock(dock, "⚙", new Intent(Settings.ACTION_SETTINGS));
        page.addView(dock, widthMatchHeightWrap());
    }

    private void showControlCenter() {
        mRoot.removeAllViews();

        LinearLayout panel = new LinearLayout(this);
        panel.setOrientation(LinearLayout.VERTICAL);
        panel.setPadding(dp(20), dp(42), dp(20), dp(24));
        panel.setBackground(gradient(
                new int[] {Color.rgb(250, 246, 243), Color.rgb(238, 225, 215)},
                GradientDrawable.Orientation.TOP_BOTTOM,
                0));
        mRoot.addView(panel, match());

        LinearLayout header = row();
        LinearLayout heading = new LinearLayout(this);
        heading.setOrientation(LinearLayout.VERTICAL);
        heading.addView(text("YiuOS ONE", 11, Typeface.BOLD, ORANGE));
        heading.addView(text("Control Center", 28, Typeface.BOLD, INK));
        header.addView(heading, new LinearLayout.LayoutParams(0, -2, 1));
        Button close = pill("×", Color.argb(28, 40, 30, 25), INK);
        close.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showHome();
                updateClock();
            }
        });
        header.addView(close);
        panel.addView(header);

        TextView promise = text(getString(R.string.privacy_summary), 12, Typeface.NORMAL, MUTED);
        LinearLayout.LayoutParams promiseParams = widthMatchHeightWrap();
        promiseParams.topMargin = dp(8);
        panel.addView(promise, promiseParams);

        GridLayout controls = new GridLayout(this);
        controls.setColumnCount(2);
        controls.setPadding(0, dp(24), 0, 0);
        addControl(controls, "⌁", "Wi-Fi", "Network settings", Settings.ACTION_WIFI_SETTINGS);
        addControl(controls, "ᛒ", "Bluetooth", "Connected devices", Settings.ACTION_BLUETOOTH_SETTINGS);
        addControl(controls, "◐", "Display", "Brightness & style", Settings.ACTION_DISPLAY_SETTINGS);
        addControl(controls, "✓", "Privacy", "Permissions", Settings.ACTION_PRIVACY_SETTINGS);
        panel.addView(controls);

        LinearLayout privacy = card();
        LinearLayout.LayoutParams privacyParams = widthMatchHeightWrap();
        privacyParams.topMargin = dp(22);
        privacy.setPadding(dp(20), dp(18), dp(20), dp(18));
        privacy.addView(text("PRIVACY GUARD", 11, Typeface.BOLD, ORANGE));
        privacy.addView(text("No apps accessed your data today.", 18, Typeface.BOLD, INK));
        TextView detail = text(
                "YiuOS ships without advertising services or product analytics. "
                        + "Use Android permissions to decide what every app can reach.",
                12, Typeface.NORMAL, MUTED);
        detail.setPadding(0, dp(8), 0, 0);
        privacy.addView(detail);
        panel.addView(privacy, privacyParams);

        Space flexible = new Space(this);
        panel.addView(flexible, new LinearLayout.LayoutParams(1, 0, 1));
        TextView build = text("YiuOS 0.3 · hinoki · Android 8.1", 11, Typeface.BOLD, MUTED);
        build.setGravity(Gravity.CENTER);
        panel.addView(build, widthMatchHeightWrap());
    }

    private void addApp(GridLayout grid, String glyph, String label, final Intent intent) {
        LinearLayout cell = new LinearLayout(this);
        cell.setOrientation(LinearLayout.VERTICAL);
        cell.setGravity(Gravity.CENTER);
        cell.setPadding(dp(2), dp(5), dp(2), dp(8));

        Button icon = pill(glyph, Color.argb(224, 255, 255, 255), INK);
        icon.setTextSize(22);
        icon.setMinWidth(dp(54));
        icon.setMinHeight(dp(54));
        icon.setOnClickListener(launchListener(intent, label));
        cell.addView(icon, new LinearLayout.LayoutParams(dp(56), dp(56)));

        TextView caption = text(label, 10, Typeface.BOLD, INK);
        caption.setGravity(Gravity.CENTER);
        LinearLayout.LayoutParams captionParams = widthMatchHeightWrap();
        captionParams.topMargin = dp(5);
        cell.addView(caption, captionParams);

        GridLayout.LayoutParams params = new GridLayout.LayoutParams();
        params.width = 0;
        params.height = ViewGroup.LayoutParams.WRAP_CONTENT;
        params.columnSpec = GridLayout.spec(GridLayout.UNDEFINED, 1f);
        grid.addView(cell, params);
    }

    private void addDock(LinearLayout dock, String glyph, final Intent intent) {
        Button button = pill(glyph, Color.TRANSPARENT, INK);
        button.setTextSize(21);
        button.setOnClickListener(launchListener(intent, glyph));
        dock.addView(button, new LinearLayout.LayoutParams(0, dp(48), 1));
    }

    private void addControl(
            GridLayout grid, String glyph, String title, String subtitle, final String action) {
        Button tile = new Button(this);
        tile.setAllCaps(false);
        tile.setGravity(Gravity.LEFT | Gravity.CENTER_VERTICAL);
        tile.setPadding(dp(16), dp(12), dp(12), dp(12));
        tile.setText(glyph + "   " + title + "\n      " + subtitle);
        tile.setTextColor(INK);
        tile.setTextSize(13);
        tile.setBackground(roundRect(Color.WHITE, dp(20)));
        tile.setOnClickListener(launchListener(new Intent(action), title));

        GridLayout.LayoutParams params = new GridLayout.LayoutParams();
        params.width = 0;
        params.height = dp(92);
        params.setMargins(dp(4), dp(4), dp(4), dp(4));
        params.columnSpec = GridLayout.spec(GridLayout.UNDEFINED, 1f);
        grid.addView(tile, params);
    }

    private View.OnClickListener launchListener(final Intent intent, final String label) {
        return new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                try {
                    startActivity(intent);
                } catch (ActivityNotFoundException exception) {
                    Toast.makeText(
                            HomeActivity.this,
                            label + " is not available in this build yet.",
                            Toast.LENGTH_SHORT).show();
                }
            }
        };
    }

    private Intent categoryIntent(String category) {
        return Intent.makeMainSelectorActivity(Intent.ACTION_MAIN, category);
    }

    private Intent typedIntent(String action, String type) {
        Intent intent = new Intent(action);
        intent.setType(type);
        if (Intent.ACTION_OPEN_DOCUMENT.equals(action)) {
            intent.addCategory(Intent.CATEGORY_OPENABLE);
        }
        return intent;
    }

    private void updateClock() {
        if (mClock != null) {
            mClock.setText(new SimpleDateFormat("HH:mm", Locale.getDefault()).format(new Date()));
        }
    }

    private LinearLayout card() {
        LinearLayout card = new LinearLayout(this);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setGravity(Gravity.CENTER_VERTICAL);
        card.setPadding(dp(16), dp(14), dp(16), dp(14));
        card.setBackground(roundRect(Color.argb(220, 255, 255, 255), dp(20)));
        return card;
    }

    private LinearLayout row() {
        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setGravity(Gravity.CENTER_VERTICAL);
        return row;
    }

    private Button pill(String label, int background, int foreground) {
        Button button = new Button(this);
        button.setAllCaps(false);
        button.setText(label);
        button.setTextColor(foreground);
        button.setTextSize(12);
        button.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        button.setMinHeight(0);
        button.setMinWidth(0);
        button.setPadding(dp(15), dp(8), dp(15), dp(8));
        button.setBackground(roundRect(background, dp(18)));
        return button;
    }

    private TextView text(String value, int size, int style, int color) {
        TextView view = new TextView(this);
        view.setText(value);
        view.setTextColor(color);
        view.setTextSize(size);
        view.setTypeface(Typeface.create("sans", style));
        return view;
    }

    private GradientDrawable roundRect(int color, int radius) {
        GradientDrawable drawable = new GradientDrawable();
        drawable.setColor(color);
        drawable.setCornerRadius(radius);
        return drawable;
    }

    private GradientDrawable gradient(
            int[] colors, GradientDrawable.Orientation orientation, int radius) {
        GradientDrawable drawable = new GradientDrawable(orientation, colors);
        drawable.setCornerRadius(radius);
        return drawable;
    }

    private LinearLayout.LayoutParams weightedCard() {
        return new LinearLayout.LayoutParams(0, dp(112), 1);
    }

    private LinearLayout.LayoutParams widthMatchHeightWrap() {
        return new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT);
    }

    private LinearLayout.LayoutParams widthWrapHeightWrap() {
        return new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT);
    }

    private FrameLayout.LayoutParams match() {
        return new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT);
    }

    private int dp(int value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }
}
