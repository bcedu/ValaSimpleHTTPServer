using Soup;

public class StylesHandler
{
# if LIBSOUP30
    public static void handler (Server server, Soup.ServerMessage msg, string path, GLib.HashTable? query) {
# else
    public static void handler (Server server, Soup.Message msg, string path, GLib.HashTable? query, Soup.ClientContext client) {
#endif
        var file = File.new_for_uri ("resource:///com/github/bcedu/resources/vserver-styles.css");
        // var input_stream = resource.open_stream ("vserver-styles.css", GLib.ResourceLookupFlags.NONE);
        var dis = new DataInputStream (file.read());
        string line = null;
        var css = new StringBuilder ();
        while ((line = dis.read_line (null)) != null) {
            css.append (line);
            css.append_c ('\n');
        }

# if LIBSOUP30
        msg.set_status(200, _("OK"));
# else
        msg.status_code = 200;
#endif
        msg.set_response ("text/css", Soup.MemoryUse.COPY, css.data);
    }
}
