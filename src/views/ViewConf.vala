using App.Controllers;
using Gtk;
using App.Widgets;

namespace App.Views {

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


    public class ViewConf : AppView, VBox {
        private Gtk.Button conf_button;
        private Gtk.Entry selected_port;

        public ViewConf (AppController controler) {
            // Add port view
            ConfPortView portv = new ConfPortView(ref selected_port, controler);
            this.pack_start (portv, true, false, 0);
            // Conf button
            conf_button = new Gtk.Button.from_icon_name ("open-menu-symbolic", Gtk.IconSize.BUTTON);
            conf_button.tooltip_text = _("Configuration");
            controler.window.headerbar.pack_end(conf_button);
            this.get_style_context().add_class ("mainbox");
            this.get_style_context().add_class ("app_view");
            this.show_all();
        }

        public string get_id() {
            return "config";
        }

        public void connect_signals(AppController controler) {
            conf_button.clicked.connect(() => {
                if (controler.view_controller.get_current_view ().get_id () != "config") {
                    controler.add_registered_view ("config");
                }
            });
        }

        public void update_view(AppController controler) {
            controler.window.headerbar.back_button.set_label (_("Save"));
            conf_button.visible = false;
            uint port = controler.httpserver.get_port();
            selected_port.set_text(port.to_string());
        }

        public void update_view_on_hide(AppController controler) {
            conf_button.visible = true;
            if (selected_port.get_text() != "0") {
                controler.httpserver.set_port(int.parse(selected_port.get_text()));
                controler.resume_sharing_files();
            }
        }

    }

}

