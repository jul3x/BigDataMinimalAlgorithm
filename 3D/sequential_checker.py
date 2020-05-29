import csv

with open('../small_dataset_3d.csv', newline='') as f:
    next(f)
    reader = csv.reader(f)

    points = []
    for row in reader:
        points.append((int(row[0]), int(row[1]), int(row[2]), int(row[3])))

    for point in points:
        greater_points = 0
        for d_point in points:
            if point[1] <= d_point[1] and point[2] <= d_point[2] and point[3] <= d_point[3]:
                greater_points = greater_points + 1

        print(str(point[0]) + ", " + str(point[1]) + ", " + str(point[2]) + ", " + str(point[3]) + " has " + str(greater_points - 1) + " greater points.")
