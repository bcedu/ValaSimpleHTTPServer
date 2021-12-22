using App.Controllers;
using Gtk;

namespace App.Views {

    public class InitialView : AppView, VBox {

        private Granite.Widgets.Welcome welcome;
        private int open_index;
        private FileChooserNative file_chooser;

        public InitialView (AppController controler) {
            welcome = new Granite.Widgets.Welcome (_("Share your files"), _("Select a folder and start sharing"));
            this.pack_start (welcome, false, false, 0);

            welcome.margin_start = welcome.margin_end = 6;
            open_index = welcome.append ("document-open", _("Open"), _("Browse to select a folder"));

            this.get_style_context().add_class ("mainbox");
            this.get_style_context().add_class ("app_view");
            this.show_all();
        }

        public string get_id() {
            return "init";
        }

        public void connect_signals (AppController controler) {
            // Connect welcome button activated
            this.welcome.activated.connect ((index) => {
                if (index == open_index) {
                    file_chooser = new Gtk.FileChooserNative (
                        _("Select a folder and start sharing"), controler.window, Gtk.FileChooserAction.SELECT_FOLDER, _("Open"), _("Cancel")
                    );

                    // Connect folder selected
                    this.file_chooser.response.connect((response) => {
                        if (response == Gtk.ResponseType.ACCEPT) {
                            string dir_selected = "";
                            string? sel = file_chooser.get_filename ();
                            if (sel != null) {
                                dir_selected = sel;
                                bool ok = controler.star_sharing_files(null, dir_selected);
                                if (ok) controler.add_registered_view( "sharing");
                                else controler.add_registered_view( "error");
                            }else {
                                controler.add_registered_view( "error");
                            }
                            file_chooser.destroy ();
                            controler.update_window_view ();
                        } else {
                            file_chooser.destroy();
                        }
                    });

                    file_chooser.run ();
                }
            });
        }

        public void update_view(AppController controler) {
            if (controler.view_controller.get_current_view().get_id() == this.get_id()) controler.stop_sharing_files();
        }

        public void update_view_on_hide(AppController controler) {
        }

    }

}
