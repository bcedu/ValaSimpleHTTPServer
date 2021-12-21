class TestSimpleHTTPServer : Gee.TestCase {
/*
print("RES---------------------------------------------\n|%s|\n", printable_uint(res));
print("ROOT_RES---------------------------------------------\n|%s|\n---------------------------------------------------------\n", printable_uint(root_res));
print_bytes(res);print_bytes(root_res);
print("-----------------------------------------------------------------------------------------------------\n");
*/

    SimpleHTTPServer server;

    public TestSimpleHTTPServer() {
        // assign a name for this class
        base("TestSimpleHTTPServer");
        // add test methods
        add_test(" 1* Test default server directory is current path (test_default_dir)", test_default_dir);
        add_test(" 2* Test default server port is in 8080 (test_default_port)", test_default_port);
        add_test(" 3* Test directory request in root (test_root_directory_ok)", test_root_directory_ok);
        add_test(" 4* Test directory request subfolder level 1 (test_subfolder_lv1_ok)", test_subfolder_lv1_ok);
        add_test(" 5* Test directory request subfolder level 2 (test_subfolder_lv2_ok)", test_subfolder_lv2_ok);
        add_test(" 6* Test directory request with index (test_directory_index_ok)", test_directory_index_ok);
        add_test(" 7* Test text file request (test_text_file_ok)", test_text_file_ok);
        add_test(" 8* Test image file request (test_image_file_ok)", test_image_file_ok);
        add_test(" 9* Test audio file request (test_audio_file_ok)", test_audio_file_ok);
        add_test(" 10* Test video file request (test_video_file_ok)", test_video_file_ok);
        add_test(" 11* Test error request (test_error_ok)", test_error_ok);
        add_test(" 12* Test special chars in filename (test_special_chars_in_filename_ok)", test_special_chars_in_filename_ok);
        add_test(" 13* Test directory request with special chars in filename (test_folder_with_special_chars_in_filename_ok)", test_folder_with_special_chars_in_filename_ok);
        add_test(" 14* Test big file request (test_big_file_ok)", test_big_file_ok);
    }

    public override void set_up () {
        server = new SimpleHTTPServer.with_port_and_path(9999, Environment.get_variable("TESTDIR")+"/fixtures/test_directory_requests");
        //server.run_async ();
        //PRINT// stdout.printf("\n");
    }

    private uint8[] make_get_request(string url) {
        MainLoop loop = new MainLoop ();
        // Create a session:
        Soup.Session session = new Soup.Session ();
        // Send a request:
        uint8[] res = "NONE".data;
        Soup.Message msg = new Soup.Message ("GET", url);
        session.queue_message (msg, (sess, mess) => {
            res = mess.response_body.data;
            // Process the result:
            //PRINT// print ("Status Code: %u\n", mess.status_code);
            //PRINT// print ("Message length: %lld\n", mess.response_body.length);
            //PRINT// print ("Data: \n%s\n", res);
            loop.quit ();
        });
        loop.run ();
        return res;
    }

    uint8[] array_concat(uint8[]a,uint8[]b){
	    uint8[] c = new uint8[a.length + b.length];
	    Memory.copy(c, a, a.length * sizeof(uint8));
	    Memory.copy(&c[a.length], b, b.length * sizeof(uint8));
	    return c;
    }

    private uint8[]  get_fixture_content(string path, bool delete_final_byte) {
        uint8[]  contents = {};
        ssize_t final_len = 0;

        string abs_path = Environment.get_variable("TESTDIR")+"/fixtures/" + path;
        File file = File.new_for_path (abs_path);
        size_t BUFFER_SIZE = 1024 * 4;
        Cancellable cancellable = new Cancellable ();
        FileInputStream file_input_stream = file.read (cancellable);
        ssize_t bytes_read = 0;
        uint8[] buffer = new uint8[BUFFER_SIZE];
        while ((bytes_read = file_input_stream.read (buffer, cancellable)) != 0) {
            if (final_len > 0) {
                contents = array_concat(contents[0:final_len], buffer[0:bytes_read]);
            } else {
                contents = buffer[0:bytes_read];
            }
            final_len += bytes_read;
        }
        if (delete_final_byte) return contents[0:contents.length-1];
        else return contents;
    }

    public string printable_uint(uint8[] bytes) {
        string res = "";
        foreach (uint8 b in bytes) {
            res += ((char)b).to_string();
        }
        return res;
    }

    public void print_bytes(uint8[] bytes) {
        print("BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB\n");
        int i = 0;
        foreach (uint8 b in bytes) {
            print("*%d-|%d|".printf(i, b));
            i+=1;
        }
        print("\nBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB\n");
    }

    public void assert_bytes(uint8[] res1, uint8[] res2) {
        if (res1.length != res2.length) print("\n\nDiferencia a la llargada . Comparant:|%d||%d|\n\n", res1.length, res2.length);
        assert (res1.length == res2.length);
        for (int i=0; i<res1.length;i++) {
            if (res1[i] != res2[i]) print("\n\nDiferencia al byte numero "+i.to_string()+". Comparant:|"+res1[i].to_string()+"||"+res2[i].to_string()+"|\n\n");
            assert (res1[i] == res2[i]);
        }
    }

    public void assert_strings(uint8[] res1, uint8[] res2) {
        string s1 = (string)res1;
        string s2 = (string)res2;
        if (s1 == null) s1 = " ";
        if (s2 == null) s2 = " ";
        s1 = s1.strip();
        s2 = s2.strip();
        assert (s1 == s2);
    }

    public void test_default_dir() {
        server = new SimpleHTTPServer.with_port(9999);
        string current = Environment.get_current_dir()+"/";
        //PRINT// stdout.printf("    - server.basedir -> %s == %s\n", current, server.basedir);
        assert(current == server.basedir);
    }

    public void test_default_port() {
        server = new SimpleHTTPServer.with_path(Environment.get_variable("TESTDIR")+"/fixtures");
        server.run_async ();
        //PRINT// stdout.printf("    - server.port -> %s == %s\n", "8080", server.port.to_string());
        assert (8080 == server.port);
        var listeners = server.get_uris();
        uint uport = listeners.nth_data(0).get_port();
        //PRINT// stdout.printf("    - listeners.nth_data(0).get_port() -> %s == %s\n", "8080", uport.to_string());
        assert (8080 == uport);
    }

    public void test_root_directory_ok() {
        //PRINT//stdout.printf("    - request '/' -> %s", "http://localhost:%d\n".printf((int)server.port));
        server.run_async();
        uint8[] res = make_get_request("http://localhost:%d\n".printf((int)server.port));
        uint8[] root_res = get_fixture_content("test_directory_requests.html", true);
        assert_bytes (res, root_res);
    }

    public void test_subfolder_lv1_ok() {
        //PRINT// stdout.printf("    - request '/' -> %s", "http://localhost:%d/carpeta_1\n".printf((int)server.port));
        server.run_async();
        uint8[] res = make_get_request("http://localhost:%d/carpeta_1\n".printf((int)server.port));
        uint8[] root_res = get_fixture_content("carpeta_1.html", true);
        assert_bytes (res, root_res);
    }

    public void test_subfolder_lv2_ok() {
        //PRINT// stdout.printf("    - request '/' -> %s", "http://localhost:%d/carpeta_1/carpeta_2\n".printf((int)server.port));
        server.run_async();
        uint8[] res = make_get_request("http://localhost:%d/carpeta_1/carpeta_2\n".printf((int)server.port));
        uint8[] root_res = get_fixture_content("carpeta_2.html", true);
        assert_bytes (res, root_res);
    }

    public void test_directory_index_ok() {
        //PRINT// stdout.printf("    - request '/' -> %s", "http://localhost:%d/carpeta_amb_index\n".printf((int)server.port));
        server.run_async();
        uint8[] res = make_get_request("http://localhost:%d/carpeta_amb_index\n".printf((int)server.port));
        uint8[] root_res = get_fixture_content("test_directory_requests/carpeta_amb_index/index.html", false);
        assert_bytes (res, root_res);
    }

    public void test_text_file_ok() {
        server.run_async();
        uint8[] res = make_get_request("http://localhost:%d/carpeta_amb_fitxers_test/text_test.txt\n".printf((int)server.port));
        uint8[] root_res = get_fixture_content("test_directory_requests/carpeta_amb_fitxers_test/text_test.txt", false);
        assert_bytes (res, root_res);
    }

    public void test_image_file_ok() {
        server.run_async();
        uint8[] res = make_get_request("http://localhost:%d/carpeta_amb_fitxers_test/img_test.jpg\n".printf((int)server.port));
        uint8[] root_res = get_fixture_content("test_directory_requests/carpeta_amb_fitxers_test/img_test.jpg", false);
        assert_bytes (res, root_res);
    }

    public void test_audio_file_ok() {
        server.run_async();
        uint8[] res = make_get_request("http://localhost:%d/carpeta_amb_fitxers_test/demo.mp3\n".printf((int)server.port));
        uint8[] root_res = get_fixture_content("test_directory_requests/carpeta_amb_fitxers_test/demo.mp3", false);
        assert_bytes (res, root_res);
    }

    public void test_video_file_ok() {
        server.run_async();
        uint8[] res = make_get_request("http://localhost:%d/carpeta_amb_fitxers_test/demo.mp4\n".printf((int)server.port));
        uint8[] root_res = get_fixture_content("test_directory_requests/carpeta_amb_fitxers_test/demo.mp4", false);
        assert_bytes (res, root_res);
    }

    public void test_big_file_ok() {
        server.run_async();
        uint8[] res = make_get_request("http://localhost:%d/carpeta_amb_fitxers_test/algo.bin\n".printf((int)server.port));
        uint8[] root_res = get_fixture_content("test_directory_requests/carpeta_amb_fitxers_test/algo.bin", false);
        assert_bytes (res, root_res);
    }

    public void test_error_ok() {
        server.run_async();
        uint8[] res = make_get_request("http://localhost:%d/carpeta_inventada\n".printf((int)server.port));
        uint8[] root_res = get_fixture_content("error.html", false);
        assert_strings (res, root_res);
    }

    public void test_special_chars_in_filename_ok() {
        server = new SimpleHTTPServer.with_port_and_path(9999, Environment.get_variable("TESTDIR")+"/fixtures/test_directory_requests_2");
        server.run_async();
        uint8[] res = make_get_request("http://localhost:%d/".printf((int)server.port)+"test_fitxer_caracters_exttranys_%20%C3%A7%C3%91%21%23%24%25%26%27%28%29%2A%2B%2C%3A%3B%3D%3F%40%5B%5D%60%C2%B4%5E%40.txt\n");
        uint8[] root_res = get_fixture_content("test_directory_requests_2/test_fitxer_caracters_exttranys_ çÑ!#$%&'()*+,:;=?@[]`´^@.txt", false);
        assert_strings (res, root_res);
    }

    public void test_folder_with_special_chars_in_filename_ok() {
        server = new SimpleHTTPServer.with_port_and_path(9999, Environment.get_variable("TESTDIR")+"/fixtures/test_directory_requests_2");
        server.run_async();
        uint8[] res = make_get_request("http://localhost:%d\n".printf((int)server.port));
        uint8[] root_res = get_fixture_content("test_directory_requests_2.html", false);
        assert_strings (res, root_res);
    }

    public override void tear_down () {
        if (server != null) {
            server.disconnect();
            server = null;
        }
    }
}
