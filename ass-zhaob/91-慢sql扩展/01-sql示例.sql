
# 效率最高的原始查询
EXPLAIN FORMAT=JSON
SELECT rental_ana.inventory_id, rental_count, i.film_id, f.title
FROM (SELECT inventory_id, COUNT(*) AS rental_count
      FROM rental r
      GROUP BY inventory_id
      ORDER BY rental_count ASC
      LIMIT 5) rental_ana
         LEFT JOIN inventory i ON rental_ana.inventory_id = i.inventory_id
         LEFT JOIN film f ON i.film_id = f.film_id;

# 更改写法1
EXPLAIN FORMAT=JSON
SELECT inventory_id, rental_count, film_id, title
FROM (
    SELECT
        r.inventory_id,
        COUNT(*) AS rental_count,
        i.film_id,
        f.title,
        ROW_NUMBER() OVER (ORDER BY COUNT(*) ASC) as rn
    FROM rental r
    LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
    LEFT JOIN film f ON i.film_id = f.film_id
    GROUP BY r.inventory_id, i.film_id, f.title
) ranked
WHERE rn <= 5
ORDER BY rental_count ASC;


# 更改写法2
EXPLAIN FORMAT=JSON
SELECT
    r.inventory_id,
    COUNT(*) AS rental_count,
    i.film_id,
    f.title
FROM rental r
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
GROUP BY r.inventory_id, i.film_id, f.title
ORDER BY rental_count ASC
LIMIT 5;


# 更改写法3
EXPLAIN FORMAT=JSON
SELECT rental_ana.inventory_id, rental_count, i.film_id, f.title
FROM (
    SELECT inventory_id, COUNT(*) AS rental_count
    FROM rental r
    WHERE EXISTS (SELECT 1 FROM inventory i WHERE i.inventory_id = r.inventory_id)
    GROUP BY inventory_id
    ORDER BY rental_count ASC
    LIMIT 5
) rental_ana
INNER JOIN inventory i ON rental_ana.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id;


