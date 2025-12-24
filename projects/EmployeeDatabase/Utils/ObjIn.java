import java.io.*;
public class ObjIn
{
      public static void main(String[] args)
      {
        String fileName = "object.out";
        int[] a = null;
        try {
          FileInputStream fileIn =
            new FileInputStream(fileName);
          ObjectInputStream in =
            new ObjectInputStream(fileIn);
          a = (int[]) in.readObject();
          in.close();
        }
        catch (IOException e) {
          System.out.println(e.getMessage());
        }
        catch (ClassNotFoundException e)
        {
          System.out.println(e.getMessage());
        }
        for (int i = 0;  i < a.length;  i++)
                System.out.println(a[i]);

      }
}
