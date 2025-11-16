-- CREATING TABLE & ROWS
CREATE TABLE aseancountries (
    region_id INT NOT NULL PRIMARY KEY,
    country_name VARCHAR(25) NOT NULL,
    azure_maturity varchar (10) NOT NULL
);

-- ADDING VALUES TO TABLE
INSERT INTO aseancountries VALUES
(1, 'Singapore', 'High'),
(2, 'Malaysia', 'Medium'),
(3, 'Indonesia', 'Medium'),
(4, 'Thailand', 'Medium'),
(5, 'Vietnam', 'Medium'),
(6, 'Philippines', 'Medium'),
(7, 'Brunei', 'Low'),
(8, 'Cambodia', 'Low'),
(9, 'Laos', 'Low'),
(10, 'Myanmar', 'Low');