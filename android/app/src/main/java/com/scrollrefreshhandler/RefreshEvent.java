package com.scrollrefreshhandler;

import androidx.annotation.Nullable;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.events.Event;

public class RefreshEvent extends Event<RefreshEvent> {

    @Deprecated
    protected RefreshEvent(int viewTag) {
        this(-1, viewTag);
    }

    protected RefreshEvent(int surfaceId, int viewTag) {
        super(surfaceId, viewTag);
    }

    @Override
    public String getEventName() {
        return "topRefresh";
    }

    @Nullable
    @Override
    protected WritableMap getEventData() {
        return Arguments.createMap();
    }
}