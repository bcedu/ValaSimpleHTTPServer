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
            welcome = new Granite.Widgets.Welcome (_("Share your files"), _("Select a folder and start sharing"));
            this.pack_start (welcome, false, false, 0);

            welcome.margin_start = welcome.margin_end = 6;
            open_index = welcome.append ("document-open", _("Open"), _("Browse to select a folder"));

            this.get_style_context().add_class ("mainbox");
            this.show_all();
        }

        public void connect_signals (AppController controler) {
            // Connect welcome button activated
            this.welcome.activated.connect ((index) => {
                if (index == open_index) {
                    file_chooser = new Gtk.FileChooserDialog (
                        _("Select packages to install"), controler.window, Gtk.FileChooserAction.SELECT_FOLDER, _("Cancel"),
                        Gtk.ResponseType.CANCEL, _("Open"), Gtk.ResponseType.ACCEPT
                    );

                    // Connect folder selected
                    this.file_chooser.response.connect((response) => {
                        if (response == Gtk.ResponseType.ACCEPT) {
                            string dir_selected = "";
                            string? sel = file_chooser.get_filename ();
                            if (sel != null) {
                                dir_selected = sel;
                                bool ok = controler.star_sharing_files(null, dir_selected);
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
                Gtk.Label maintext = new Gtk.Label (_("Your files are at "));
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

    public class ConfigView : AppView, VBox {
        private Gtk.Entry selected_port;
        private Gtk.Button back_button;
        private Gtk.Button menu_button;

        public ConfigView(AppController controler) {
            // Add port view
            ConfPortView portv = new ConfPortView(ref selected_port, controler);
            this.pack_start (portv, true, false, 0);
            // Add button to go back in headerbar
            back_button = new Gtk.Button ();
            back_button.label = "Save";
            back_button.visible = false;
            back_button.get_style_context ().add_class ("back-button");
            controler.headerbar.pack_start(back_button);
            // Add settings button in headerbar
            menu_button = new Gtk.Button ();
            menu_button.set_image (new Gtk.Image .from_icon_name ("open-menu-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
            menu_button.tooltip_text = _("Settings");
            controler.headerbar.pack_end (menu_button);
            // Set view style
            this.get_style_context().add_class ("mainbox");
            this.show_all();
        }

        public void connect_signals (AppController controler) {
            back_button.clicked.connect(() => {
                if (selected_port.get_text() != "0") controler.httpserver.set_port(int.parse(selected_port.get_text()));
                controler.view_controler.state = "init";
                controler.update_window_view();
                back_button.visible = false;
            });
            menu_button.clicked.connect(() => {
                controler.stop_sharing_files();
                controler.view_controler.state = "config";
                back_button.visible = true;
                controler.update_window_view();
            });
            return;
        }

        public void update_view(AppController controler) {
            uint port = controler.httpserver.get_port();
            selected_port.set_text(port.to_string());
            if (controler.view_controler.state != "config") back_button.visible = false;
            else back_button.visible = true;
        }

        public class ConfPortView : Gtk.HBox {

            public ConfPortView (ref Gtk.Entry? selected_port, AppController controler) {
                Gtk.Label maintext = new Gtk.Label (_("Listening at port: "));
                maintext.get_style_context().add_class ("app_text");
                this.pack_start (maintext, true, false, 0);
                selected_port = new Gtk.Entry();
                uint port = controler.httpserver.get_port();
                selected_port.set_text(port.to_string());
                this.pack_start (selected_port, true, false, 0);
            }
        }
    }

}
