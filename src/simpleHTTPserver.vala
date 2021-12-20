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
using Soup;
using App.Configs;

public class SimpleHTTPServer : Soup.Server {
        public string basedir;
        public uint port;
        public signal void sig_directory_requested(Soup.Message msg, File file);
        public signal void sig_file_requested(Soup.Message msg, File file);
        public signal void sig_error(Soup.Message msg, File file);
        public static bool log = false;


        public SimpleHTTPServer () {
                this.with_port_and_path(8080, Environment.get_current_dir());
        }

        public SimpleHTTPServer.with_path(string path) {
                this.with_port_and_path(8080, path);
        }

       public SimpleHTTPServer.with_port(int port) {
                this.with_port_and_path(port, Environment.get_current_dir());
       }

        public SimpleHTTPServer.with_port_and_path(int port, string path) {
                assert (this != null);
                this.port = port;
                if (path == "" || path == "/") this.basedir = "/";
                else {
                    this.basedir = path;
                    if (this.basedir.get_char(this.basedir.length-1) != '/') this.basedir = this.basedir + "/";
                }
                this.add_handler (null, default_handler);
                this.sig_directory_requested.connect(dir_handle);
                this.sig_file_requested.connect(file_handle);
                this.sig_error.connect(error_handle);
        }

        public void run_async() {
            this.listen_all(this.port, 0);
        }

        public void run() {
            log = true;
            MainLoop loop = new MainLoop ();
            this.listen_all(this.port, 0);
            print(_("Listening on: ")+get_link()+"\n");
			loop.run ();
        }

        private static string normalize_path(string path) {
            if (path == "/") return path;
            string normalized_path = "";
            foreach (string partial_path in path.split("/")) {
                if (partial_path != "") normalized_path += "/%s".printf(Soup.URI.encode(partial_path, null));
            }
            // Caracters que el encode del URI no fa no se perque, ja que també son caracters especials...
            normalized_path = normalized_path.replace("!", "%21");
            normalized_path = normalized_path.replace("#", "%23");
            normalized_path = normalized_path.replace("$", "%24");
            normalized_path = normalized_path.replace("&", "%26");
            normalized_path = normalized_path.replace("'", "%27");
            normalized_path = normalized_path.replace("(", "%28");
            normalized_path = normalized_path.replace(")", "%29");
            normalized_path = normalized_path.replace("*", "%2A");
            normalized_path = normalized_path.replace("+",  "%2B");
            normalized_path = normalized_path.replace(",", "%2C");
            normalized_path = normalized_path.replace(":", "%3A");
            normalized_path = normalized_path.replace(";", "%3B");
            normalized_path = normalized_path.replace("=", "%3D");
            normalized_path = normalized_path.replace("?", "%3F");
            normalized_path = normalized_path.replace("@", "%40");
            normalized_path = normalized_path.replace("[", "%5B");
            normalized_path = normalized_path.replace("]", "%5D");
            //print("\nEncoded vs No encoded:|%s||%s|\n", normalized_path, path);
            return normalized_path;
        }

        private static void default_handler (Server server, Soup.Message msg, string path, GLib.HashTable? query, Soup.ClientContext client) {
            // The default handler checks the type of the file requested (the file is calculated with basedir + request_path)
            // Then, if it is a directory sends the signal sig_directory_requested of server.
            // If it is a file sends the signal sig_file_requested of server.
            // And if the file doesn't exists sends the signal sig_erro of server
            unowned SimpleHTTPServer self = server as SimpleHTTPServer;
            if (msg.uri.get_path() == "favicon.ico") return;
            string rel_path = msg.get_uri().get_path();
            File rfile;
            if (rel_path == "/" && self.basedir == "/")  rfile = File.new_for_path(rel_path);
            else  rfile = File.new_for_path(self.basedir+rel_path);
            //PRINT// stdout.printf("====================================================\nSTART of Request\n");
            var ftype = rfile.query_file_type (FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
            if (log) stdout.printf(_("Requested: %s, full path: %s\n"), rel_path, rfile.get_path());
            msg.status_code = 200;
            // PRINT // stdout.printf("TYPE: %s\n", ftype.to_string());
            if (ftype == FileType.DIRECTORY) self.sig_directory_requested(msg, rfile);
            else if (ftype == FileType.REGULAR) self.sig_file_requested(msg, rfile);
            else self.sig_error(msg, rfile);
            //PRINT// stdout.printf("END of Request\n======================================================\n");
        }

        private void dir_handle(Soup.Message msg, File file) {
            if (has_index(file)) this.send_index(msg, file);
            else this.send_list_dir(msg, file);
        }

        private void file_handle(Soup.Message msg, File file) {
            this.send_file(msg, file);
        }

        private void error_handle(Soup.Message msg, File file) {
            msg.set_response ("text/html", Soup.MemoryUse.COPY, "<html><head><title>404</title></head><body><h1>404</h1><p>File not found.</p></body></html>".data);
            msg.status_code = 404;
        }

        private bool has_index(File file) {
            FileEnumerator enumerator = file.enumerate_children ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
    	    FileInfo info = null;
    	    while (((info = enumerator.next_file (null)) != null)) {
    	        if (info.get_name () == "index.html") return true;
    	    }
            return false;
        }

        private void send_index(Soup.Message msg, File file) {
            File index = File.new_for_path(file.get_path()+"/index.html");
            this.send_file(msg, index);
        }

        private void send_list_dir(Soup.Message msg, File file) {
            string newindex = "<html><body>";
            File fbase = File.new_for_path(basedir);
            string base_rel_path = file.get_path().substring(fbase.get_path().length)+"/";
            newindex = _("%s<h1>Listing files of: %s</h1>").printf(newindex, base_rel_path);
            if (fbase.get_path() != file.get_path() &&  file.has_parent(null)) {
                File parent = file.get_parent();
                string rel_path = parent.get_path().substring(fbase.get_path().length);
                if (rel_path == "") rel_path = "/";
                //PRINT// stdout.printf("Parent: %s\n", rel_path);
                newindex = "%s<ul>%s</ul>".printf(newindex, add_link(rel_path, "../"));
            }
            FileEnumerator enumerator = file.enumerate_children ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
            FileInfo info = null;
            newindex = "%s%s".printf(newindex, "<ul>");
            while (((info = enumerator.next_file (null)) != null)) {
                //PRINT// stdout.printf("Child: %s%s\n", base_rel_path, info.get_name());
                newindex = "%s%s".printf(newindex, add_link(base_rel_path + info.get_name(), null));
            }
            newindex = "%s</ul></body></html>".printf(newindex);
            msg.set_response ("text/html", Soup.MemoryUse.COPY, newindex.data);
        }

        private static string add_link(string path, string? name) {
            string spath = name;
            if (spath == null) {
                if (path == "/") spath = "/";
                else spath = path.split("/")[path.split("/").length-1];
            }
            string normalized_path = normalize_path(path);
            return "<li><a href=\"%s\">%s</a></li>".printf(normalized_path, spath);
        }

        private void send_file(Soup.Message msg, File file) {
            MainLoop loop = new MainLoop ();
            file.load_contents_async.begin (null, (obj, res) => {
		        try {
	                uint8[] contents;
		            string etag_out;
			        file.load_contents_async.end (res, out contents, out etag_out);
                    string type = get_file_type(file);
			        msg.set_response (type, Soup.MemoryUse.COPY, contents);
		        } catch (Error e) {
			        print ("Error: %s\n", e.message);
		        }

		        loop.quit ();
	        });
	        loop.run ();
            //PRINT//
            //print("TYPE: %s\nCONTENT:\n--------------------------------\n|%s|\n--------------------------------\n", type, (string)content);
            //print("===============================================\n%s\n===============================================\n", content.length.to_string());
            //msg.set_response (type, Soup.MemoryUse.COPY, content);
            //msg.response_headers.set_content_length(content.data.length);
        }

        private static uint8[] get_file_content(File file) {
            uint8[] contents;
            string etag_out;
            try {
                try {
                    file.load_contents (null, out contents, out etag_out);
                }catch (Error e){
                    error("%s", e.message);
                }
            }catch (Error e){
                error("%s", e.message);
            }
            //PRINT//stderr.printf("CONTENT: %d ||%s||\nSTR: %d ||%s||\n", contents.length, (string) contents, ((string)contents).data.length, (string) (((string)contents).strip()).data);
            return contents;
        }

        private static string get_file_type(File file) {
            string res = "text/text";
            try {
                FileInfo inf = file.query_info("*", 0);
                res = inf.get_content_type();
                //print("\n%s   -> type: %s\n", file.get_path(), res);
            }catch (Error e){
                error("%s", e.message);
            }
            return res;
        }

        public string get_link() {
            return "http://"+resolve_server_address()+":"+this.port.to_string();
        }
        public string resolve_server_address() {
            try {
                // Resolve hostname to IP address
               var resolver = Resolver.get_default ();
               var addresses = resolver.lookup_by_name ("www.google.com", null);
               var address = addresses.nth_data (0);

               var client = new SocketClient ();
               var conn = client.connect (new InetSocketAddress (address, 80));
               InetSocketAddress local = conn.get_local_address() as InetSocketAddress;
               return local.get_address().to_string();
            } catch (Error e){
                return "0.0.0.0";
            }
        }
        public uint get_port() {
            return this.port;
        }
        public void set_port(int nport) {
            this.port = nport;
        }

        // public static int main (string[] args) {
        //         SimpleHTTPServer server = new SimpleHTTPServer.with_path ("");
        //         server.run ();
        //         return 0;
        // }
}
