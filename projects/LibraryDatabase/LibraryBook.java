public class LibraryBook 
{
    private static int numBooks = 0;
    private String title;
    private String author;
    private int copyright;
    private double price;
    private String genre;
    
    // Constructor for book.
    public LibraryBook (String booktitle, String authorname, int cpyright, double bookprice, String ngenre)
    {
        numBooks++;
        title = booktitle;
        author = authorname;
        copyright = cpyright;
        price = bookprice;
        genre = ngenre;
    }
    
    // Returns title of book.
    public String getTitle()
    {
        return title;
    }
    
    // Returns author of book.
    public String getAuthor()
    {
        return author;
    }
    
    // Returns copyright year of book.
    public int getCopyright()
    {
        return copyright;
    }
    
    public double getPrice()
    {
        return price;
    }
    
    public String getGenre()
    {
        return genre;
    }
    
    public int compareTo (LibraryBook book2)
    {
        return title.compareTo(book2.getTitle());
    }
}
