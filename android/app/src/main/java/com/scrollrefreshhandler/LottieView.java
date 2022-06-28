package com.scrollrefreshhandler;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RadialGradient;
import android.graphics.Shader;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.OvalShape;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.widget.ImageView;
import android.widget.LinearLayout;

import androidx.core.content.ContextCompat;
import androidx.core.view.ViewCompat;

import com.airbnb.lottie.LottieAnimationView;
import com.airbnb.lottie.LottieDrawable;

/**
 * Private class created to work around issues with AnimationListeners being
 * called before the animation is actually complete and support shadows on older
 * platforms.
 */
@SuppressLint("AppCompatCustomView")
class LottieView extends LinearLayout {
    private Animation.AnimationListener mListener;

    LottieAnimationView lottie;

    LottieView(Context context) {
        super(context);

        lottie = new LottieAnimationView(getContext());
        lottie.setAnimation("animation.json");
        lottie.setRepeatCount(LottieDrawable.INFINITE);
        lottie.playAnimation();

        lottie.setLayoutParams(new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT));

        addView(lottie);
    }

    public void setAnimationListener(Animation.AnimationListener listener) {
        mListener = listener;
    }

    @Override
    public void onAnimationStart() {
        super.onAnimationStart();
        if (mListener != null) {
            mListener.onAnimationStart(getAnimation());
        }
    }

    @Override
    public void onAnimationEnd() {
        super.onAnimationEnd();
        if (mListener != null) {
            mListener.onAnimationEnd(getAnimation());
        }
    }
}
