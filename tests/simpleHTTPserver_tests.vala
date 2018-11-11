class TestSimpleHTTPServer : Gee.TestCase {

    SimpleHTTPServer server;

    public TestSimpleHTTPServer() {
        // assign a name for this class
        base("TestSimpleHTTPServer");
        // add test methods
        add_test(" * Test default server directory is current path (test_default_dir)", test_default_dir);
        add_test(" * Test default server port is in 8080 (test_default_port)", test_default_port);
        add_test(" * Test directory request in root (test_default_port)", test_root_directory_ok);
        add_test(" * Test directory request subfolder level 1 (test_subfolder_lv1_ok)", test_subfolder_lv1_ok);
        add_test(" * Test directory request subfolder level 2 (test_subfolder_lv2_ok)", test_subfolder_lv2_ok);
        add_test(" * Test directory request with index (test_directory_index_ok)", test_directory_index_ok);
        add_test(" * Test file request (test_file_ok)", test_file_ok);
        add_test(" * Test error request (test_error_ok)", test_error_ok);
    }

    public override void set_up () {
        server = new SimpleHTTPServer.with_port_and_path(9999, Environment.get_current_dir()+"/fixtures/test_directory_requests");
        //server.run_async ();
        //PRINT// stdout.printf("\n");
    }

    private string make_get_request(string url) {
        MainLoop loop = new MainLoop ();
        // Create a session:
        Soup.Session session = new Soup.Session ();
        // Send a request:
        string res = "NONE";
        Soup.Message msg = new Soup.Message ("GET", url);
        session.queue_message (msg, (sess, mess) => {
            res = (string) mess.response_body.data;
            // Process the result:
            //PRINT// print ("Status Code: %u\n", mess.status_code);
            //PRINT// print ("Message length: %lld\n", mess.response_body.length);
            //PRINT// print ("Data: \n%s\n", res);
            loop.quit ();
        });
        loop.run ();
        return res;
    }

    private uint8[] get_fixture_content(string path) {
        string abs_path = Environment.get_current_dir()+"/fixtures/" + path;
        File file = File.new_for_path (abs_path);
        /*var file_stream = file.read ();
        var data_stream = new DataInputStream (file_stream);
        data_stream.set_byte_order (DataStreamByteOrder.LITTLE_ENDIAN);
        uint8[] contents = new uint8[8];
        int readed = 0;
        try {
            while (true) {
                if (contents.length <= readed) contents.resize(readed*2);
                contents[readed] = data_stream.read_byte();
                readed += 1;
            }
        } catch (Error e) {}
        contents = contents[0:readed-1];*/
        uint8[] contents;
        try {
            try {
                string etag_out;
                file.load_contents (null, out contents, out etag_out);
            }catch (Error e){
                error("%s", e.message);
            }
        }catch (Error e){
            error("%s", e.message);
        }
        return contents;
    }

    public void test_default_dir() {
        server = new SimpleHTTPServer.with_port(9999);
        string current = Environment.get_current_dir()+"/";
        //PRINT// stdout.printf("    - server.basedir -> %s == %s\n", current, server.basedir);
        assert(current == server.basedir);
    }

    public void test_default_port() {
        server = new SimpleHTTPServer.with_path(Environment.get_current_dir()+"/fixtures");
        server.run_async ();
        //PRINT// stdout.printf("    - server.port -> %s == %s\n", "8080", server.port.to_string());
        assert (8080 == server.port);
        var listeners = server.get_uris();
        uint uport = listeners.nth_data(0).get_port();
        //PRINT// stdout.printf("    - listeners.nth_data(0).get_port() -> %s == %s\n", "8080", uport.to_string());
        assert (8080 == uport);
    }

    public void test_root_directory_ok() {
        //PRINT// stdout.printf("    - request '/' -> %s", "http://localhost:%d\n".printf((int)server.port));
        server.run_async();
        string res = make_get_request("http://localhost:%d\n".printf((int)server.port));
        string root_res = (string)get_fixture_content("test_directory_requests.html");
        assert (res == root_res);
    }

    public void test_subfolder_lv1_ok() {
        //PRINT// stdout.printf("    - request '/' -> %s", "http://localhost:%d/carpeta_1\n".printf((int)server.port));
        server.run_async();
        string res = make_get_request("http://localhost:%d/carpeta_1\n".printf((int)server.port));
        string root_res = (string)get_fixture_content("carpeta_1.html");
        assert (res == root_res);
    }

    public void test_subfolder_lv2_ok() {
        //PRINT// stdout.printf("    - request '/' -> %s", "http://localhost:%d/carpeta_1/carpeta_2\n".printf((int)server.port));
        server.run_async();
        string res = make_get_request("http://localhost:%d/carpeta_1/carpeta_2\n".printf((int)server.port));
        string root_res = (string)get_fixture_content("carpeta_2.html");
        assert (res == root_res);
    }

    public void test_directory_index_ok() {
        //PRINT// stdout.printf("    - request '/' -> %s", "http://localhost:%d/carpeta_amb_index\n".printf((int)server.port));
        server.run_async();
        string res = make_get_request("http://localhost:%d/carpeta_amb_index\n".printf((int)server.port));
        string root_res = (string)get_fixture_content("test_directory_requests/carpeta_amb_index/index.html");
        assert (res == root_res);
    }

    public void test_file_ok() {

    }

    public void test_error_ok() {
    }

    public override void tear_down () {
        if (server != null) {
            server.disconnect();
            server = null;
        }
    }
}

