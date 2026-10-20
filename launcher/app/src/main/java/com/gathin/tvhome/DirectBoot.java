package com.gathin.tvhome;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.UserManager;

/**
 * The accessibility helpers are directBootAware: some firmware (TPV Philips Google TV 14) clears
 * enabled_accessibility_services of services that are not, while the user is still locked at boot, so a
 * helper enabled over ADB was gone after each restart. Before unlock the credential-protected storage
 * that Config reads (preferences, the theme's config.json) is not there yet, so the work waits for it.
 */
final class DirectBoot {

    private DirectBoot() {
    }

    /** Runs a task once the user is unlocked: now, or on ACTION_USER_UNLOCKED. */
    static final class Unlock {
        private final Runnable task;
        private BroadcastReceiver receiver;

        Unlock(Runnable task) {
            this.task = task;
        }

        void whenUnlocked(Context ctx) {
            if (ctx.getSystemService(UserManager.class).isUserUnlocked()) {
                task.run();
                return;
            }
            receiver = new BroadcastReceiver() {
                @Override
                public void onReceive(Context c, Intent intent) {
                    cancel(ctx);
                    task.run();
                }
            };
            ctx.registerReceiver(receiver, new IntentFilter(Intent.ACTION_USER_UNLOCKED));
        }

        void cancel(Context ctx) {
            if (receiver == null) return;
            ctx.unregisterReceiver(receiver);
            receiver = null;
        }
    }
}
