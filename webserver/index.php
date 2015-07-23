<?php

error_reporting(E_ALL);
if ($_FILES["uploadedfile"]["error"] > 0)
{
    echo "Return Code: " . $_FILES["uploadedfile"]["error"] .
"<br />";
}
else
{


    $allowedExts = array("db", "txt", "zip");
    $temp = explode(".", $_FILES["uploadedfile"]["name"]);
    $extension = end($temp);
    if(!in_array($extension, $allowedExts))
        die("That Extension is not allowed");

    echo "Upload successful <br />";
    echo "Upload: " . $_FILES["uploadedfile"]["name"] . "<br />";
    echo "Type: " . $_FILES["uploadedfile"]["type"] . "<br />";
    echo "Size: " . ($_FILES["uploadedfile"]["size"] / 1024) . " Kb<br />";

    move_uploaded_file($_FILES["uploadedfile"]["tmp_name"],
        "/mnt/s3/globallit-tabletdata/" .time()."-".$_FILES["uploadedfile"]["name"]);
}

