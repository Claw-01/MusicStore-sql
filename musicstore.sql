
-- Given a database called musicstore:

use musicstore;

-- Let's see how many F.Baltes tracks there are:

SELECT COUNT(TrackId)
FROM track
WHERE Composer LIKE '%F. Baltes%';

-- Show the number of invoices and the num of invoics with a total amount of 0.99 in the same query:

SELECT COUNT(invoice.InvoiceId) AS Facturas,
	SUM(CASE WHEN invoice.Total = 0.99
        THEN 1
        ELSE 0
	END) AS 'Facturas = 0,99'
FROM invoice;

-- Display the album title and artist name of the first five albums in alphabetical order:

SELECT album.Title, artist.Name
FROM 
	album
		JOIN artist ON album.ArtistId = artist.ArtistId
ORDER BY album.Title ASC
LIMIT 5;

-- List the ID, first name and last name of the first 10 customers in alphabetical order. Include ID, first and last name from support representative:
 
SELECT customer.CustomerId, customer.FirstName, customer.LastName, customer.SupportRepId
FROM customer
ORDER BY customer.FirstName, customer.LastName ASC
LIMIT 10;

SELECT customer.CustomerId, customer.FirstName, customer.LastName, customer.SupportRepId
FROM customer
ORDER BY customer.FirstName, customer.LastName ASC;

-- List track name, duration, album title, artist name, the media and genre type of the 5 longest tracks:

SELECT track.Name, track.Milliseconds, album.Title, artist.Name, mediatype.Name, genre.Name
FROM 
	track
		JOIN album ON track.AlbumId = album.AlbumId
        JOIN artist ON album.ArtistId = artist.artistId
        JOIN mediatype ON track.MediaTypeId = mediatype.MediaTypeId
        JOIN genre ON track.GenreId = genre.GenreId
ORDER BY track.Milliseconds DESC
LIMIT 5;

-- Let's find the 5 most expensive albums:

SELECT album.Title, sum(track.UnitPrice), avg(track.UnitPrice)
FROM 
	track
		JOIN album ON track.AlbumId = album.AlbumId
GROUP BY album.Title
ORDER BY sum(track.UnitPrice) DESC
LIMIT 5;

-- From the previous query above, filter by those whose average price per track is greater than 1

SELECT album.title, SUM(track.unitprice) AS expensive, AVG(track.unitprice) 
FROM track
JOIN album ON track.albumid = album.albumid
GROUP BY album.title
HAVING AVG(track.unitprice) > 1
ORDER BY expensive DESC
LIMIT 5;

-- List the album ID and the number of different genres (for those albums with more than one genre) and show the result ordered by the number of different genres:
SELECT album.AlbumId, COUNT(DISTINCT genre.GenreId)
FROM
	album
    JOIN track ON album.AlbumId = track.AlbumId
    JOIN genre ON track.GenreId = genre.GenreId
GROUP BY album.AlbumId
HAVING COUNT(DISTINCT genre.GenreId) >= 2
ORDER BY COUNT(DISTINCT genre.GenreId) DESC;

-- Show the total number of albums from the previous result:

SELECT COUNT(*)
FROM (SELECT album.AlbumId, COUNT(DISTINCT genre.GenreId)
	FROM
	album
    JOIN track ON album.AlbumId = track.AlbumId
    JOIN genre ON track.GenreId = genre.GenreId
	GROUP BY album.AlbumId
	HAVING COUNT(DISTINCT genre.GenreId) >= 2
	ORDER BY COUNT(DISTINCT genre.GenreId) DESC)
AS TOTAL;


-- Verify that the total amount of money on each invoice be equal to the sum of the unit price x the quantity of the invoice lines:

SELECT 
		invoice.InvoiceId, 
		invoice.Total, 
        SUM(invoiceline.UnitPrice * invoiceline.Quantity) AS Suma,
		CASE 
			WHEN invoice.Total = SUM(invoiceline.UnitPrice * invoiceline.Quantity) THEN 'True'
			ELSE 'False'
			END AS Comprobar
FROM 
	invoice
	JOIN invoiceline ON invoice.InvoiceId = invoiceline.InvoiceId
GROUP BY invoice.InvoiceId;

-- Show those employees whose clients have generated the largest num of invoices:

SELECT CONCAT(employee.FirstName, " ",employee.LastName) AS Empleado, SUM(invoice.Total) AS MontoTotal, COUNT(invoice.InvoiceId) AS NFacturas
FROM 
	employee
		JOIN customer ON employee.EmployeeId = customer.SupportRepId
        JOIN invoice ON customer.CustomerId = invoice.CustomerId
GROUP BY Empleado
ORDER BY COUNT(invoice.InvoiceId) DESC;


-- Display active customer information:

SELECT TOTAL.CustomerId, TOTAL.AVGGastoCliente, TOTAL.AVGFactCliente, TOTAL2.AVGGastoFact
FROM 
	(SELECT invoice.CustomerId, AVG(invoice.Total) AS AVGGastoCliente, COUNT(invoice.Total) AS AVGFactCliente
	FROM invoice
	GROUP BY invoice.CustomerId) AS TOTAL
JOIN
	(SELECT invoice.invoiceId, AVG(invoice.Total) AS AVGGastoFact
	FROM invoice
	GROUP BY invoice.invoiceId) AS TOTAL2;


-- How many customers are above the average spending per customer:


SELECT COUNT(*)
FROM
	(
	SELECT invoice.CustomerId, SUM(invoice.Total) AS GastoCliente
	FROM invoice
	GROUP BY invoice.CustomerId
	) AS GastoPorCliente
WHERE GastoCliente > 
		(
		SELECT AVG(GastoCliente)
		FROM (
			SELECT SUM(invoice.Total) AS GastoCliente
			FROM invoice
			GROUP BY invoice.CustomerId
			) AS Gasto2
		);

    
-- The most purchased artist, the most profitable artist and the most listened:

(SELECT artist.Name, 'Total Quantity' AS Concept, COUNT(invoiceline.Quantity) as Value
FROM 
	artist
    JOIN album ON artist.ArtistId = album.ArtistId
    JOIN track ON album.AlbumId = track.AlbumId
    JOIN invoiceline ON track.TrackId = invoiceline.TrackId
GROUP BY artist.artistId
ORDER BY Value DESC
LIMIT 1)
UNION
(SELECT artist.Name, 'Total Amount' AS Concept, SUM(invoiceline.UnitPrice * invoiceline.Quantity) as Value
FROM 
	artist
    JOIN album ON artist.ArtistId = album.ArtistId
    JOIN track ON album.AlbumId = track.AlbumId
    JOIN invoiceline ON track.TrackId = invoiceline.TrackId
GROUP BY artist.artistId
ORDER BY Value DESC
LIMIT 1)
UNION
(SELECT artist.Name, 'Total Time' AS Concept, SUM(track.Milliseconds)/1000 AS Value
FROM 
	artist
    JOIN album ON artist.ArtistId = album.ArtistId
    JOIN track ON album.AlbumId = track.AlbumId
    JOIN invoiceline ON track.TrackId = invoiceline.TrackId
    GROUP BY artist.artistId
    ORDER BY Value DESC
	LIMIT 1)
;
