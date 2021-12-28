using App.Controllers;
using Qrencode;
using Gdk;
using Gtk;
namespace App.Views {

    public class ResumeView : Gtk.Box {

        public ResumeView (ref Gtk.LinkButton? direcciolink, ref Gtk.Label? sharedpath, AppController controler) {
            this.set_orientation(Gtk.Orientation.VERTICAL);

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


    public class SharingView : AppView, Box {

        private Gtk.LinkButton direcciolink;
        private Gtk.Label sharedpath;
        private Gtk.Button back_button;
        private Image image_qr;

        public SharingView (AppController controler) {
            this.set_orientation(Gtk.Orientation.VERTICAL);
            
            // Add resume view
            var resumebox = new ResumeView(ref direcciolink, ref sharedpath, controler);
            this.pack_start (resumebox, true, false, 0);

            image_qr = new Image();
            resumebox.pack_start (image_qr, false, false, 20);

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

            int width = controler.httpserver.qrcode.width;
            int height = controler.httpserver.qrcode.width;

            int square_size = 10;
            int screen_width = width * square_size;
            int screen_height = height * square_size;

            Cairo.ImageSurface surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, screen_width, screen_height);
            Cairo.Context context = new Cairo.Context (surface);
            context.save();
            for (int iy = 0; iy < width; iy++) {
                for (int ix = 0; ix < height; ix++) {
                    if ((controler.httpserver.qrcode.data[iy * width + ix] & 1) != 0) {
                        context.set_source_rgb(0, 0, 0);
                        context.rectangle(ix * square_size, iy * square_size, square_size, square_size);
                        context.fill();
                    }else{
                        context.set_source_rgb(255, 255, 255);
                        context.rectangle(ix * square_size, iy * square_size, square_size, square_size);
                        context.fill();
                    }
                }
            }
            context.restore();
            image_qr.clear();
            image_qr.set_from_surface(surface);

        }


        public void update_view_on_hide(AppController controler) {
            controler.stop_sharing_files();
        }

    }

}
