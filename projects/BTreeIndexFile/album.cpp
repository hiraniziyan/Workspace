#include "album.h"
#include <iostream>
#include <cstring>

using namespace std;

Album::Album()
{
    	strcpy(UPC, "");
    	strcpy(Artist, "");
    	strcpy(Title, "");
}

Album::Album(String upc, String artist, String title)
{
    	strcpy(UPC, upc);
    	strcpy(Artist, artist);
    	strcpy(Title, title);
}

Album::Album(const Album& otherAlbum)
{
    	strcpy(UPC, otherAlbum.UPC);
    	strcpy(Artist, otherAlbum.Artist);
    	strcpy(Title, otherAlbum.Title);
}

Album& Album::operator=(const Album& otherAlbum)
{
     	strcpy(UPC, otherAlbum.UPC);
        strcpy(Artist, otherAlbum.Artist);
	strcpy(Title, otherAlbum.Title);
    	return *this;
}	

bool operator<(const Album& a, const Album& b)
{
    	return strcmp(a.UPC, b.UPC) < 0;
}

bool operator>(const Album& a, const Album& b)
{
        return strcmp(b.UPC, a.UPC) < 0;
}

bool operator == (const Album& a, const Album& b)
{
        return strcmp(b.UPC, a.UPC) == 0;
}


istream& operator>>(istream& stream, Album& C)
{
    	stream.getline(C.UPC, UpTo);
    	stream.getline(C.Artist, UpTo);
    	stream.getline(C.Title, UpTo);
    	return stream;
}

ostream& operator<<(ostream& stream, Album& C)
{
	stream << C.UPC << "|" << C.Artist << "|" << C.Title << "|" << endl;
    	return stream;
}

string Album::getUPC()
{
    	return string(UPC);
}

int Album::recordSize()
{
    	return sizeof(UPC) + sizeof(Artist) + sizeof(Title);
}

