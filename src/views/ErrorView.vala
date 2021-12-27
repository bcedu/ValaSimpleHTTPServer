using App.Controllers;
using Gtk;
using App.Widgets;

namespace App.Views {


    public class ErrorView : AppView, Box {
        private Gtk.Button conf_button;

        public ErrorView (AppController controler) {
            this.set_orientation(Gtk.Orientation.VERTICAL);
        }

        public string get_id() {
            return "error";
        }

        public void connect_signals(AppController controler) {
        }

        public void update_view(AppController controler) {
        }

        public void update_view_on_hide(AppController controler) {
        }

    }

}

