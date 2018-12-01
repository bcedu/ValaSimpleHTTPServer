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

using App.Widgets;
using App.Views;

namespace App.Controllers {

    /**
     * The {@code AppController} class.
     *
     * @since 1.0.0
     */
    public class AppController {

        public  App.Application            application;
        public  ViewControler              view_controler;
        public  SimpleHTTPServer           httpserver;
        public  Gtk.HeaderBar              headerbar;
        public  Gtk.ApplicationWindow      window { get; private set; default = null; }

        /**
         * Constructs a new {@code AppController} object.
         */
        public AppController (App.Application application) {
            this.application = application;
            this.window = new AppWindow (this.application);
            this.headerbar = new HeaderBar ();
            this.view_controler = new ViewControler (this);

            this.update_window_view();
            this.window.set_titlebar (this.headerbar);
            this.application.add_window (window);
            this.connect_signals();

            httpserver = new SimpleHTTPServer.with_port(8888);
            httpserver.disconnect();
        }

        public void update_window_view() {
            this.window.forall ((element) => {
                if (element is AppView) {
                    this.window.remove (element);
                }
            });
            var aux = this.view_controler.get_current_view();
            aux.update_view(this);
            this.window.add (aux);
        }

        public void activate () {
            window.show_all ();
            update_window_view();
        }

        public void quit () {
            window.destroy ();
            httpserver.disconnect();
        }

        private void connect_signals() {
            this.view_controler.connect_signals(this);
        }

        public bool star_sharing_files(int? port, string? path) {
            if (httpserver == null) httpserver = new SimpleHTTPServer();
            httpserver.disconnect();
            if (port != null) httpserver.port = port;
            if (path != null) httpserver.basedir = path;
            httpserver.run_async ();
            print("Server is listening on: "+httpserver.get_link()+"\n");
            return true;
        }

        public void stop_sharing_files() {
            httpserver.disconnect();
        }

    }
}
