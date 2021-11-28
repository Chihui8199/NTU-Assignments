import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.SocketException;

public class Rfc865UdpServer {
    public static void main(String[] argv) {
        // 1. Open UDP socket at well-known port
        DatagramSocket socket= null;
        try {
            socket = new DatagramSocket();
        } catch (SocketException e) {}
        while (true) {
            try {
                // 2. Listen for UDP request from client
                byte[] b1 = new byte[1024];
                DatagramPacket request = new DatagramPacket(b1,b1.length);
                socket.receive(request);
                String str= new String(request.getData());

                // 3. Send UDP Reply to Client
                InetAddress address = request.getAddress();
                int port = request.getPort();
                DatagramPacket reply = new DatagramPacket(b1,b1.length,address, port);
                socket.send(reply);
            } catch (IOException e) {}
        }

    }

}
