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
using App.Controllers;
using App.Views;

namespace App {

    /**
     * Class responsible for creating the u window and will contain contain other widgets.
     * allowing the user to manipulate the window (resize it, move it, close it, ...).
     *
     * @see Gtk.ApplicationWindow
     * @since 1.0.0
     */
    public class AppWindow : Gtk.ApplicationWindow {

        /**
         * Constructs a new {@code AppWindow} object.
         *
         * @see App.Configs.Constants
         * @see style_provider
         * @see build
         */
        public AppWindow (Gtk.Application app) {
            Object (
                application: app,
                icon_name: Constants.APP_ICON,
                resizable: true
            );

            this.init_css();
            this.set_default_size (800, 640);
            this.set_size_request (800, 640);

            return;
            int x = Application.settings.get_int ("window-x");
            int y = Application.settings.get_int ("window-y");

            if (x != -1 && y != -1) {
                move (x, y);
            }
            // Save the window's position on close
            delete_event.connect (() => {
                int root_x, root_y;
                get_position (out root_x, out root_y);

                Application.settings.set_int ("window-x", root_x);
                Application.settings.set_int ("window-y", root_y);
                return false;
            });
        }

        public void init_css() {
            // Load CSS
            var provider = new Gtk.CssProvider();
            try {
                string cssdata = """
                    mainbox, .mainbox {
                      background-color: white;
                    }

                    select_folder_label, .app_text {
                      /* font-weight: bolder; */
                      color: #333333;
                      font-size: 18px;
                    }

                    app_button, .app_button {
                      font-weight: bolder;
                      color: #5B5B5B;
                      /* border-color: white; */
                      background-color: white;
                      font-size: 15px;
                     }
                    app_button:hover, .app_button:hover{
                      /* background-color: grey; */
                      background-color: ghostwhite;
                    }
                """;
                provider.load_from_data(cssdata);
                Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch (Error e) {
                stderr.printf("\nError: %s\n", e.message);
            }
        }
    }
}
