using App.Controllers;
using Gtk;
namespace App.Views {

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


    public class SharingView : AppView, VBox {

        private Gtk.LinkButton direcciolink;
        private Gtk.Label sharedpath;
        private Gtk.Button back_button;

        public SharingView (AppController controler) {
            // Add resume view
            var resumebox = new ResumeView(ref direcciolink, ref sharedpath, controler);
            this.pack_start (resumebox, true, false, 0);
            // Set view style
            this.get_style_context().add_class ("mainbox");
            this.get_style_context().add_class ("app_view");
            this.show_all();
        }

        public string get_id() {
            return "sharing";
        }

        public void connect_signals (AppController controler) {
            return;
        }

        public void update_view(AppController controler) {
            string direccio = controler.httpserver.get_link();
            direcciolink.set_uri(direccio);
            direcciolink.set_label(direccio);
        }


        public void update_view_on_hide(AppController controler) {
            controler.stop_sharing_files();
        }

    }

}
