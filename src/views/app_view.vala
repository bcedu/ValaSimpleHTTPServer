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
using App.Controllers;
using Gtk;

namespace App.Views {

    /**
     * The {@code AppView} class.
     *
     * @since 1.0.0
     */
    public interface AppView : VBox {
        public abstract void connect_signals (AppController controler);
    }

    public class InitialView : AppView, VBox {

        private FileChooserButton file_chooser;
        private Button continue_button;

        public InitialView () {
            var welcome = new Granite.Widgets.Welcome ("Welcome!", "Start sharing your files");
            this.pack_start (welcome, false, false, 0);

            var chooserbox = new FolderSelectView(ref file_chooser);
            this.pack_start (chooserbox, true, false, 0);

            var buttonbox = new ContinueButtonView(ref continue_button);
            this.pack_start (buttonbox, true, false, 0);

            this.get_style_context().add_class ("mainbox");
        }

        public void connect_signals (AppController controler) {
            this.continue_button.clicked.connect(() => {
                string dir_selected = "";
                string? sel = file_chooser.get_filename ();
                if (sel != null) {
                    dir_selected = sel;
                    bool ok = controler.star_sharing_files(8888, dir_selected);
                    if (ok) controler.view_controler.state = "sharing";
                    else controler.view_controler.state = "error";
                }else {
                    controler.view_controler.state = "error";
                }
                controler.update_window_view();
            });
        }

        public class FolderSelectView : Gtk.HBox {

            public FolderSelectView (ref FileChooserButton? chooser) {
                var lb = new Label("Which folder do you want to share?");
                lb.get_style_context().add_class ("select_folder_label");

                chooser = new FileChooserButton("Which folder do you want to share?", Gtk.FileChooserAction.SELECT_FOLDER);
                chooser.select_multiple = false;

                this.pack_start (lb, true, false, 0);
                this.pack_end (chooser, true, false, 0);
            }
        }

        public class ContinueButtonView : Gtk.HBox {

            public ContinueButtonView (ref Button? continue_button) {
                continue_button = new Button.with_label("Continue");
                continue_button.get_style_context().add_class ("continue_button");
                continue_button.set_relief(ReliefStyle.NONE);
                this.pack_start (continue_button, true, true, 0);
            }
        }

    }

    public class SharingView : AppView, VBox {
        public void connect_signals (AppController controler) {
            return;
        }
    }
    public class ErrorView : AppView, VBox {
        public void connect_signals (AppController controler) {
            return;
        }
    }

}
