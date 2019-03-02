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
using App.Views;
using Gee;

namespace App.Controllers {

    /**
     * The {@code AppController} class.
     *
     * @since 1.0.0
     */
    public class ViewControler {

        private HashMap<string, AppView>    state_to_view_dict;
        public string                       state;

        public ViewControler (AppController controler) {
            this.state = "init";
            this.state_to_view_dict = new HashMap<string, AppView>();
            // The initial view
            InitialView initv = new InitialView(controler);
            this.state_to_view_dict.set("init", initv);
            // The sharing view
            SharingView sharev = new SharingView(controler);
            this.state_to_view_dict.set("sharing", sharev);
            // The error view
            ErrorView errorv = new ErrorView(controler);
            this.state_to_view_dict.set("error", errorv);
            // The config view
            ConfigView configv = new ConfigView(controler);
            this.state_to_view_dict.set("config", configv);
        }

        public void connect_signals(AppController controler) {
            var it = state_to_view_dict.map_iterator ();
            for (var has_next = it.next (); has_next; has_next = it.next ()) {
                it.get_value().connect_signals(controler);
            }
        }

        public AppView get_current_view() {
            //stdout.printf("Current state: %s\n", this.state);
            return state_to_view_dict[this.state];
        }

        public void update_views(AppController controler) {
            foreach (AppView v in state_to_view_dict.values) {
                v.update_view(controler);
            }
        }

    }
}
