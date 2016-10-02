<?php 
require '../database.php';
$Code = null;
if ( !empty($_GET['Code'])) {
	$Code = $_REQUEST['Code'];
}

if ( null==$Code ) {
	header("Location: ../index.php");
} else {
	$pdo = Database::connect();
	$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
	$sql = "SELECT Movies.Code, Title, Plot, Movies.Type, Movies.Category, Image, Score, Rated, Alt, Status, YearReleased, Duration, SUBSTRING(Duration, 1, CHAR_LENGTH(Duration) - 3) AS Duration2, TotalEps, Types.code as tcode, Types.Type as ttype, Categories.Code as ccode, Categories.Category as ca, Ratings.Code as rc, Ratings.Rating as rr FROM Movies, Types, Categories, Ratings WHERE Movies.Type=Types.Code AND Movies.Rated=Ratings.Code AND Movies.Category=Categories.Code AND Movies.Code = ?";
	$sql2="SELECT GenreCode, Genre FROM MovieGenres, Genres Where MovieGenres.GenreCode=Genres.Code AND MovieGenres.MovieCode= ?";
	$sql3="SELECT DISTINCT Formats.Format, Audio, Subtitles, FormatCode, AudioLang, SeasonNum, VolumeNum, DiscNum, Location, EpPerDisc, Extra, DiscTitle, Title, Note FROM MediaInfo LEFT JOIN Formats ON MediaInfo.FormatCode=Formats.code LEFT JOIN AudioLangs ON MediaInfo.AudioLang=AudioLangs.Code LEFT JOIN Movies ON MediaInfo.Extra=Movies.Code WHERE MediaInfo.MovieCode = ?";
	$sql4="SELECT MovieCode, Relation, SecondMovie, Title FROM MovieRelations, Relations, Movies WHERE MovieRelations.MovieCode=Movies.Code AND MovieRelations.RelationCode=Relations.Code AND MovieRelations.SecondMovie= ?";
	$sql5="SELECT Movies.Type FROM Movies WHERE Movies.Code = ?";
	$q = $pdo->prepare($sql);
	$q->execute(array($Code));
	$data = $q->fetch(PDO::FETCH_ASSOC);
	Database::disconnect();
}
?>

<!DOCTYPE html>
<html lang="en">

<head>

	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta name="apple-mobile-web-app-capable" content="yes">
	<meta name="description" content="">
	<meta name="author" content="">

	<title>MovieDB - <?php echo $data['Title'];?></title>

	<!-- Bootstrap Core CSS -->
	<link href="../css/bootstrap.min.css" rel="stylesheet">

	<!-- Custom CSS -->
	<link href="../css/modern-business.css" rel="stylesheet">
	<link href="../css/custom.css" rel="stylesheet">

	<!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
	<!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
        <![endif]-->

    </head>

    <body>

    	<!-- Navigation -->
    	<?php include '../include/nav.php';?>

    	<!-- Page Content -->
    	<div class="container">

    		<!-- Page Heading/Breadcrumbs -->
    		<div class="row">
    			<div class="col-lg-12">
    				<h2 class="page-header"><?php echo $data['Title'];?>
    				</h2>
    			</div>
    		</div>
    		<!-- /.row -->

    		<!-- Portfolio Item Row -->
    		<div class="row">
    			<div class="col-md-4">
    				<img class="img-responsive" src="../Images/<?php echo $data['Image'];?>" alt="">
    			</div>


    			<div class="col-md-8 hidden-xs">
    				<ul class="nav nav-tabs">
    					<li class="active"><a data-toggle="tab" href="#Plot">Plot</a></li>
    					<li><a data-toggle="tab" href="#Details">Details</a></li>
    					<li><a data-toggle="tab" href="#Formats">Formats</a></li>
    					<li><a data-toggle="tab" href="#Related">Related</a></li>
    					<li><a data-toggle="tab" href="#User">User</a></li>
    				</ul>
    				<div class="tab-content">
    					<div id="Plot" class="tab-pane fade in active">
    						<br>
    						<p><?php echo nl2br($data['Plot']);?></p>
    					</div>
    					<div id="Details" class="tab-pane fade">
    						<?php
    						echo '<br>';
    						echo'<li>Alternative Title:  '. $data['Alt'] .'</li>';
    						echo'<li>Type:  <a href="../list/type.php?Code='. $data['tcode'] .'&Type='. $data['ttype'] .'">'. $data['ttype'] .'</a></li>';
    						echo'<li>Rated:  <a href="../list/rating.php?Code='. $data['rc'] .'&Rating='. $data['rr'] .'">'. $data['rr'] .'</a></li>';
    						echo'<li>Episodes:  '. $data['TotalEps'] .'</li>';
    						echo'<li>Duration:  '. $data['Duration2'] .'</li>';

    						echo'<li>Genre: ';
    						$count=0;
    						$g = $pdo->prepare($sql2);
    						$g->execute(array($Code));
    						while ($row = $g->fetch(PDO::FETCH_ASSOC)) {
    							if ($count > 0) {
    								echo ", ";
    								echo'<a href="../list/genre.php?GenreCode='. $row['GenreCode'] .'&Genre='. $row['Genre'] .'">'. $row['Genre'] .'</a>';

    							}
    							else {
    								echo'<a href="../list/genre.php?GenreCode='. $row['GenreCode'] .'&Genre='. $row['Genre'] .'">'. $row['Genre'] .'</a>';
    								$count++;
    							}
    						}
    						echo '</li>';

    						echo'<li>Status:  '. $data['Status'] .'</li>';
    						echo'<li>Category:  <a href="../list/categories.php?Code='. $data['ccode'] .'&Category='. $data['ca'] .'">'. $data['ca'] .'</a></li>';
    						echo'<li>Year Released:  <a href="../list/year.php?Year='. $data['YearReleased'] .'">'. $data['YearReleased'] .'</a></li>';
    						echo'<li>Score:  '. $data['Score'] .'</li>';
    						?>
    					</div>
    					<div id="Formats" class="tab-pane fade">
    						<?php
    						$count=0;
    						$f = $pdo->prepare($sql5);
    						$f->execute(array($Code));
    						while ($row3 = $f->fetch(PDO::FETCH_ASSOC)) {

    							if (''. $row3['Type'] .''=="Movie"){
    								$count=0;
    								$f = $pdo->prepare($sql3);
    								$f->execute(array($Code));
    								while ($row3 = $f->fetch(PDO::FETCH_ASSOC)) {
    									echo '<br>';
    									echo'<li>Format:  <a href="../list/format.php?FormatCode='. $row3['FormatCode'] .'&Format='. $row3['Format'] .'">'. $row3['Format'] .'</a></li>';
    									echo'<li>Audio:  <a href="../list/audio.php?AudioLang='. $row3['AudioLang'] .'&Audio='. $row3['Audio'] .'">'. $row3['Audio'] .'</a></li>';
    									echo'<li>Subtitle:  '. $row3['Subtitles'] .'</li>';
    									echo'<li>Location:  '. $row3['Location'] .'</li>';
    								}    								}
    								elseif (''. $row3['Type'] .''=="TV") {
    									$count=0;
    									$f = $pdo->prepare($sql3);
    									$f->execute(array($Code));
    									while ($row3 = $f->fetch(PDO::FETCH_ASSOC)) {
    										echo '<br>';
    										echo'<li>Format:  <a href="../list/format.php?FormatCode='. $row3['FormatCode'] .'&Format='. $row3['Format'] .'">'. $row3['Format'] .'</a></li>';
    										echo'<li>Audio:  <a href="../list/audio.php?AudioLang='. $row3['AudioLang'] .'&Audio='. $row3['Audio'] .'">'. $row3['Audio'] .'</a></li>';
    										echo'<li>Subtitle:  '. $row3['Subtitles'] .'</li>';
    										echo'<li>Location:  '. $row3['Location'] .'</li>';
    										echo'<li>Season #:  '. $row3['SeasonNum'] .'</li>';
    										echo'<li>Volume #:  '. $row3['VolumeNum'] .'</li>';
    										echo'<li>Disc #:  '.$row3['DiscNum'] .'</li>';
    										echo'<li>Episode Per Disc:  '. $row3['EpPerDisc'] .'</li>';
    										echo'<li>Extra:  <a href="../detail/index.php?Code='.$row3['Extra'].'">'. $row3['Title'] .'</a></li>';
    										echo'<li>Note:  '.$row3['Note'] .'</li>';
    									}    								}

    								}
    								?>
    							</div>
    							<div id="Related" class="tab-pane fade in">
    								<?php
    								$count=0;
    								$r = $pdo->prepare($sql4);
    								$r->execute(array($Code));
    								while ($row4 = $r->fetch(PDO::FETCH_ASSOC)) {
    									echo'<br>';
    									echo'<li>'. $row4['Relation'] .':  <a href="../detail/index.php?Code='.$row4['MovieCode'].'">'. $row4['Title'] .'</a></li>';
    								}
    								?>
    							</div>
    							<div id="User" class="tab-pane fade in">
    								<br>
    								<p>Under Construction</p>
    							</div>
    						</div>
    					</div>


    					<!-- Phone & tablet Portrait Section -->

    					<div class="col-md-12 hidden-sm hidden-md hidden=-lg">
    						<h3>Plot</h3>
    						<p><?php echo $data['Plot'];?></p>
    					</div>
    					<div class="col-md-12 hidden-sm hidden-md hidden=-lg ">
    						<h3>Details</h3>
    						<?php
    						echo'<li>Alternative Title:  '. $data['Alt'] .'</li>';
    						echo'<li>Type:  <a href="../list/type.php?Code='. $data['tcode'] .'&Type='. $data['ttype'] .'">'. $data['ttype'] .'</a></li>';
    						echo'<li>Rated:  <a href="../list/rating.php?Code='. $data['rc'] .'&Rating='. $data['rr'] .'">'. $data['rr'] .'</a></li>';
    						echo'<li>Episodes:  '. $data['TotalEps'] .'</li>';
    						echo'<li>Duration:  '. $data['Duration2'] .'</li>';

    						echo'<li>Genre: ';
    						$count=0;
    						$g = $pdo->prepare($sql2);
    						$g->execute(array($Code));
    						while ($row = $g->fetch(PDO::FETCH_ASSOC)) {
    							if ($count > 0) {
    								echo ", ";
    								echo'<a href="../list/genre.php?GenreCode='. $row['GenreCode'] .'&Genre='. $row['Genre'] .'">'. $row['Genre'] .'</a>';

    							}
    							else {
    								echo'<a href="../list/genre.php?GenreCode='. $row['GenreCode'] .'&Genre='. $row['Genre'] .'">'. $row['Genre'] .'</a>';
    								$count++;
    							}
    						}
    						echo '</li>';

    						echo'<li>Status:  '. $data['Status'] .'</li>';
    						echo'<li>Category:  <a href="../list/categories.php?Code='. $data['ccode'] .'&Category='. $data['ca'] .'">'. $data['ca'] .'</a></li>';
    						echo'<li>Year Released:  <a href="../list/year.php?Year='. $data['YearReleased'] .'">'. $data['YearReleased'] .'</a></li>';
    						echo'<li>Score:  '. $data['Score'] .'</li>';
    						?>
    					</div>
    					<div class="col-md-12 hidden-sm hidden-md hidden=-lg">
    						<h3>Formats</h3>
    						<?php
    						$count=0;
    						$f = $pdo->prepare($sql3);
    						$f->execute(array($Code));
    						while ($row3 = $f->fetch(PDO::FETCH_ASSOC)) {
    							echo'<li>Format:  <a href="../list/format.php?FormatCode='. $row3['FormatCode'] .'&Format='. $row3['Format'] .'">'. $row3['Format'] .'</a></li>';
    							echo'<li>Audio:  <a href="../list/audio.php?AudioLang='. $row3['AudioLang'] .'&Audio='. $row3['Audio'] .'">'. $row3['Audio'] .'</a></li>';
    							echo'<li>Subtitle:  '. $row3['Subtitles'] .'</li>';
    							echo'<li>Location:  '. $row3['Location'] .'</li>';
    							echo'<br>';
    						}
    						?>
    					</div>
    				</div>

    				<!-- /.row -->



    				<hr>

    				<!-- Footer -->
    				<?php include '../include/footer.php';?>

    				<!-- /.container -->

    				<!-- jQuery -->
    				<script src="../js/jquery.js"></script>

    				<!-- Bootstrap Core JavaScript -->
    				<script src="../js/bootstrap.min.js"></script>
    			</body>

    			</html>