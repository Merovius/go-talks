module example.com/foo

go 1.19

retract v1.0.0 // Published accidentally.

retract [v1.0.0, v1.9.9]
