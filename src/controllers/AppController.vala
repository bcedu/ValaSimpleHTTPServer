/*
* Copyright (C) 2018  Eduard Berloso Clarà <eduard.bc.95@gmail.com>
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero General Public License as published
* by the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero General Public License for more details.
*
* You should have received a copy of the GNU Affero General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
*/
using App.Configs;
using App.Widgets;


namespace App.Controllers {

    public class AppController {
        /**
         * Constructs a new {@code AppController} object.
         * The AppControler manages all the elements of the applications.
         */
        public App.Application application;
        public SimpleHTTPServer httpserver;
        public AppWindow window;
        public ViewController view_controller;
#if LIBUNITY
        public Unity.LauncherEntry launcher;
#endif

        public AppController (App.Application application) {
            this.application = application;
            // Create the main window
            this.window = new AppWindow (this.application);
            this.application.add_window (this.window);
            // Create the view_controller;
            this.view_controller = new ViewController (this);
            // Connect the signals
            this.connect_signals();
#if LIBUNITY
            this.launcher = Unity.LauncherEntry.get_for_desktop_id (Constants.LAUNCHER_ID);
#endif
            this.httpserver = new SimpleHTTPServer.with_port(8888);
            this.httpserver.disconnect();
        }

        public void activate () {
            // Show all elements from window
            window.init ();
            // Set current view
            this.update_window_view ();
        }

        public void quit () {
            // Close the window
            window.destroy ();
        }

        public void update_window_view() {
            this.window.clean ();
            this.view_controller.update_views ();
            var aux = this.view_controller.get_current_view ();
            this.window.add (aux);
        }

        public void add_registered_view(string view_id) {
            this.view_controller.add_registered_view (view_id);
            this.update_window_view ();
        }

        public void set_registered_view(string view_id) {
            this.view_controller.set_registered_view (view_id);
            this.update_window_view ();
        }

        private void connect_signals() {
            // Signals of views
            this.view_controller.connect_signals ();
            // Signal for back button
            this.window.headerbar.back_button.clicked.connect (() => {
                this.view_controller.get_previous_view ();
                this.view_controller.get_current_view ();
                this.update_window_view ();
		    });
        }

        public void notify(string text) {
            var notification = new Notification (Constants.APP_NAME);
            try {
                notification.set_icon ( new Gdk.Pixbuf.from_file (Constants.APP_ICON));
            }catch (GLib.Error e) {
                stdout.printf("Notification logo not found. Error: %s\n", e.message);
            }
            notification.set_body (text);
            this.application.send_notification (this.application.application_id, notification);
        }

        public bool star_sharing_files(int? port, string? path) {
            if (httpserver == null) httpserver = new SimpleHTTPServer();
            httpserver.disconnect();
            if (port != null) httpserver.port = port;
            if (path != null) httpserver.basedir = path;
            httpserver.run_async ();
            print(_("Server is listening on: ")+httpserver.get_link()+"\n");
            return true;
        }

        public bool resume_sharing_files() {
            if (httpserver == null) return false;
            httpserver.disconnect();
            httpserver.run_async ();
            print(_("Server is listening on: ")+httpserver.get_link()+"\n");
            return true;
        }

        public void stop_sharing_files() {
            httpserver.disconnect();
        }

    }
}
