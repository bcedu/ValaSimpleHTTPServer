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

public class SimpleHTTPServer : Soup.Server {
        public static string basedir;

        public SimpleHTTPServer () {
                this.with_port_and_path(8088, "");
        }

        public SimpleHTTPServer.with_path(string path) {
                this.with_port_and_path(8088, path);
        }

       public SimpleHTTPServer.with_port(int port) {
                this.with_port_and_path(port, "");
       }

        public SimpleHTTPServer.with_port_and_path(int port, string path) {
                Object (port: port);
                assert (this != null);
                if (path == "" || path == "/") this.basedir = "/";
                else {
                    this.basedir = path;
                    if (this.basedir.get_char(this.basedir.length-1) != '/') this.basedir = this.basedir + "/";
                }
                this.add_handler (null, default_handler);
        }

        private static void default_handler (Server server, Soup.Message msg, string path, GLib.HashTable? query, Soup.ClientContext client) {
                if (msg.uri.get_path() == "favicon.ico") return;
                string rel_path = msg.get_uri().get_path();
                File rfile;
                if (rel_path == "/" && basedir == "/")  rfile = File.new_for_path(rel_path);
                else  rfile = File.new_for_path(basedir+rel_path);
                stdout.printf("Requested: %s, full path: %s\n", rel_path, rfile.get_path());
                var ftype = rfile.query_file_type (FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
                if (ftype == FileType.DIRECTORY) dir_handle(server, msg, rfile);
                else if (ftype == FileType.REGULAR) file_handle(server, msg, rfile);
                else error_handle(server, msg, rfile);
                stdout.printf("END of Request\n======================================================\n");
        }

        private static void dir_handle(Server server, Soup.Message msg, File file) {
            if (has_index(file)) send_index(server, msg, file);
            else send_list_dir(server, msg, file);
        }

        private static void file_handle(Server server, Soup.Message msg, File file) {
        }

        private static void error_handle(Server server, Soup.Message msg, File file) {
            msg.set_response ("text/html", Soup.MemoryUse.COPY, "<html><head><title>404</title></head><body><h1>404</h1><p>File not found.</p></body></html>".data);
            msg.status_code = 404;
        }

        private static  bool has_index(File file) {
            FileEnumerator enumerator = file.enumerate_children ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
    	    FileInfo info = null;
    	    while (((info = enumerator.next_file (null)) != null)) {
    	        if (info.get_name () == "index.html") return true;
    	    }
            return false;
        }

        private static void send_index(Server server, Soup.Message msg, File file) {
            msg.set_response ("text/html", Soup.MemoryUse.COPY, "<html><head><title>404</title></head><body><h1>Index</h1></body></html>".data);
        }

        private static void send_list_dir(Server server, Soup.Message msg, File file) {
            string newindex = "<html><body>";
            File fbase = File.new_for_path(basedir);
            if (fbase.get_path() != file.get_path() &&  file.has_parent(null)) {
                File parent = file.get_parent();
                string rel_path = parent.get_path().substring(fbase.get_path().length);
                if (rel_path == "") rel_path = "/";
                stdout.printf("Parent: %s\n", rel_path);
                newindex = "%s%s".printf(newindex, add_link(rel_path, "../"));
            }
            string base_rel_path = file.get_path().substring(fbase.get_path().length)+"/";
            FileEnumerator enumerator = file.enumerate_children ("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
            FileInfo info = null;
            while (((info = enumerator.next_file (null)) != null)) {
                stdout.printf("Child: %s%s\n", base_rel_path, info.get_name());
                newindex = "%s%s".printf(newindex, add_link(base_rel_path + info.get_name(), null));
            }
            newindex = "%s</body></html>".printf(newindex);
            msg.set_response ("text/html", Soup.MemoryUse.COPY, newindex.data);
        }

        private static string add_link(string path, string? name) {

            string spath = name;
            if (spath == null) {
                if (path == "/") spath = "/";
                else spath = path.split("/")[path.split("/").length-1];
            }
            return "<br><a href=\"%s\">%s</a>".printf(path, spath);
        }

        // public static int main (string[] args) {
        //         SimpleHTTPServer server = new SimpleHTTPServer.with_path ("");
        //         server.run ();
        //         return 0;
        // }
}
