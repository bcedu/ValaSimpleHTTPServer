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

public class Main {
    private static bool version = false;
    private static bool no_interface = false;
    private static int port = 0;
    private static string? path = null;

    private const OptionEntry[] options = {
        {"version", 0, 0, OptionArg.NONE, ref version, "Display Version Number", null },
        {"no-interface", 0, 0, OptionArg.NONE, ref no_interface, "Open an http server without gui.", null },
        {"directory", 'd', 0, OptionArg.FILENAME, ref path, "Directory to share", "DIRECTORY"},
        {"port", 'p', 0, OptionArg.INT, ref port, "Port where server will be listening", "INT"},
        { null }
    };

    /**
     * Main method. Responsible for starting the {@code Application} class.
     *
     * @see App.Application
     * @return {@code int}
     * @since 1.0.0
     */
    public static int main (string [] args) {
        var options_context = new OptionContext (App.Configs.Constants.APP_NAME +" "+ "Options");
        options_context.set_help_enabled (true);
        options_context.add_main_entries (options, null);

        try {
            options_context.parse (ref args);
        }
        catch (Error error) {}

        if (version) {
            stdout.printf (App.Configs.Constants.APP_NAME +" "+ App.Configs.Constants.VERSION + "\r\n");
            return 0;
        } else if (no_interface) {
            SimpleHTTPServer server;
            if (port != 0 && path != null) {
                server = new SimpleHTTPServer.with_port_and_path(port, path);
            }else if (port != 0) {
                server = new SimpleHTTPServer.with_port(port);
            }else if (path != null) {
                server = new SimpleHTTPServer.with_path(path);
            }else {
                server = new SimpleHTTPServer();
            }
            server.run();
            return 0;
        } else {
            var app = new App.Application ();
            app.run (args);
        }

        return 0;
    }
}
