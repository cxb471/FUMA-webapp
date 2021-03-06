@extends('layouts.master')
@section('head')
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
<script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
<script type="text/javascript">
var loggedin = "{{ Auth::check() }}";
$(document).ready(function(){
	$('#snp2genebtn').on('click', function(){
		window.location.href="{{ Config::get('app.subdir') }}/snp2gene";
	});

	$('#gene2funcbtn').on('click', function(){
		window.location.href="{{ Config::get('app.subdir') }}/gene2func";
	});
});
</script>
@stop
@section('content')
<div class="container" style="padding-top:50px;">
	<div style="text-align: center;">
		<h2>FUMA GWAS</h2>
		<h2>Functional Mapping and Annotation of Genome-Wide Association Studies</h2>
	</div>
	<br/>
	<p>
		FUMA is a platform that can be used to annotate, prioritize, visualize and interpret GWAS results.
		<br/>
		The <a href="{{ Config::get('app.subdir') }}/snp2gene">SNP2GENE</a> function takes GWAS summary statistics as an input,
		and provides extensive functional annotation for all SNPs in genomic areas identified by lead SNPs.
		<br/>
		The <a href="{{ Config::get('app.subdir') }}/gene2func">GENE2FUNC</a> function takes a list of geneids (as identified by SNP2GENE or as provided manually)
		and annotates genes in biological context
		<br/>
		To submit your own GWAS, logis is required for security reason.
		If you have't registered yet, you can do from <a href="{{ url('/register') }}">here</a>.
		<br/>
		You can browse example results of FUMA for a few GWAS from <a href="{{ Config::get('app.subdir') }}/browse">Browse Examples</a> without registoration or login.
	</p>
	<p>
		When using FUMA, please cite the following.<br/>
		K. Watanabe, E. Taskesen, A. van Bochoven and D. Posthuma. FUMA: Functional mapping and annotation of genetic associations. <i>bioRxiv.</i> <a target="_blank" href="http://biorxiv.org/content/early/2017/02/20/110023">https://doi.org/10.1101/110023.</a> (2017).
	</p>
	<p>
		Please post any questions, suggestions and bug reports on Google Forum: <a target="_blank" href="https://groups.google.com/forum/#!forum/fuma-gwas-users">FUMA GWAS users</a>.
	</p>
	<br/>

	<div class="row">
		<div class="col-md-6 col-xs-6 col-sm-6" style="text-align:center; padding: 20px;">
			<div style="background-color: #dfdfdf; padding-top:20px; padding-bottom:20px;">
				<!-- <h4 class="blinking" style="color:#000099">Start from here with GWAS summary statistics</h4> -->
				<button id="snp2genebtn" class="btn btn-primary">SNP2GENE</button>
				<br/><br/>
				<img src="{{ URL::asset('/image/homeSNP2GENE.png') }}" align="middle" style="width:90%;">
			</div>
		</div>
		<div class="col-md-6 col-xs-6 col-sm-6" style="text-align:center; padding: 20px;">
			<div style="background-color: #dfdfdf; padding-top:20px; padding-bottom:20px;">
				<!-- <h4 class="blinking" style="color:#000099">Start from here with a list of genes</h4> -->
				<button id="gene2funcbtn" class="btn btn-success">GENE2FUNC</button>
				<br/><br/>
				<img src="{{ URL::asset('/image/homeGENE2FUNC.png') }}" align="middle" style="width:90%;">
			</div>
		</div>
	</div>
</div>
</br>
@stop
