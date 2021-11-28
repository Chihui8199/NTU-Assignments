import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.io.IOException;
import java.net.SocketException;
import java.net.UnknownHostException;

public class Rfc865UdpClient {

    public static void main(String[] argv) throws SocketException {
        //Name: Ng Chi Hui
        //Group: FDDP1
        //Ip Address: 172.21.151.141

        // 1. Open UDP socket
        System.out.println("START");
        DatagramSocket socket = new DatagramSocket();

        try {
            socket = new DatagramSocket();
        } catch (SocketException e) {
        }

        try {
            // 2. Send UDP request to server
            String msg = new String("Ng Chi Hui, FDDP1 , 172.21.151.141");
            InetAddress address = InetAddress.getByName("Swlab2-c.scse.ntu.edu.sg");
            byte[] buf = msg.getBytes();


            DatagramPacket request = new DatagramPacket(buf, buf.length, address, 17);
            socket.send(request);
            // 3. Receive UDP reply from server
            DatagramPacket reply = new DatagramPacket(buf, buf.length);
            socket.receive(reply);
            String received = new String(reply.getData(), 0, reply.getLength());
            System.out.println("Message send: " + msg);
            System.out.println("Message received: " + received);
            System.out.println("Your PC IP address: " + "172.21.151.141");
            System.out.println("Quote of Day server IP address: " + "172.21.148.202");

        } catch (IOException e) {
        }
        socket.close();

    }


}
