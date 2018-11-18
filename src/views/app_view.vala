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
        public abstract void update_view(AppController controler);
    }

    public class InitialView : AppView, VBox {

        private FileChooserDialog file_chooser;
        private Granite.Widgets.Welcome welcome;
        private int open_index;

        public InitialView (AppController controler) {
            welcome = new Granite.Widgets.Welcome ("Share your files", "Select a folder and start sharing");
            this.pack_start (welcome, false, false, 0);

            welcome.margin_start = welcome.margin_end = 6;
            open_index = welcome.append ("document-open", "Open", "Browse to select a folder");

            this.get_style_context().add_class ("mainbox");
            this.show_all();
        }

        public void connect_signals (AppController controler) {
            // Connect welcome button activated
            this.welcome.activated.connect ((index) => {
                if (index == open_index) {
                    file_chooser = new Gtk.FileChooserDialog (
                        "Select packages to install", controler.window, Gtk.FileChooserAction.SELECT_FOLDER, "Cancel", 
                        Gtk.ResponseType.CANCEL, "Open", Gtk.ResponseType.ACCEPT
                    );

                    // Connect folder selected
                    this.file_chooser.response.connect((response) => {
                        if (response == Gtk.ResponseType.ACCEPT) {
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
                            file_chooser.destroy ();
                            controler.update_window_view();
                        } else {
                            file_chooser.destroy();
                        }
                    });

                    file_chooser.run ();
                }
            });
        }

        public void update_view(AppController controler) {

        }

    }

    public class SharingView : AppView, VBox {
        private Gtk.LinkButton direcciolink;
        private Gtk.Label sharedpath;
        private Gtk.Button back_button;

        public SharingView(AppController controler) {
            // Add resume view
            var resumebox = new ResumeView(ref direcciolink, ref sharedpath, controler);
            this.pack_start (resumebox, true, false, 0);
            // Add button to go back in headerbar
            back_button = new Gtk.Button ();
            back_button.label = "Back";
            back_button.visible = false;
            back_button.get_style_context ().add_class ("back-button");
            controler.headerbar.pack_start(back_button);
            // Set view style
            this.get_style_context().add_class ("mainbox");
            this.show_all();
        }

        public void connect_signals (AppController controler) {
            back_button.clicked.connect(() => {
                controler.stop_sharing_files();
                controler.view_controler.state = "init";
                controler.update_window_view();
                back_button.visible = false;
            });
            return;
        }

        public void update_view(AppController controler) {
            string direccio = controler.httpserver.get_link();
            direcciolink.set_uri(direccio);
            direcciolink.set_label(direccio);
            if (controler.view_controler.state != "sharing") back_button.visible = false;
            else back_button.visible = true;
        }

        public class ResumeView : Gtk.VBox {

            public ResumeView (ref Gtk.LinkButton? direcciolink, ref Gtk.Label? sharedpath, AppController controler) {
                Gtk.Label maintext = new Gtk.Label ("Your files are at ");
                maintext.get_style_context().add_class ("app_text");
                this.pack_start (maintext, false, false, 0);

                string direccio = controler.httpserver.get_link();
                if (direccio == "" || direccio == null) direccio = "";
                direcciolink = new Gtk.LinkButton(direccio);
                direcciolink.get_style_context().add_class ("app_button");
                this.pack_start (direcciolink, false, false, 0);
            }
        }
    }

    public class ErrorView : AppView, VBox {

        public ErrorView(AppController controler) {

        }

        public void connect_signals (AppController controler) {
            return;
        }
        public void update_view(AppController controler) {
            
        }
    }

}
