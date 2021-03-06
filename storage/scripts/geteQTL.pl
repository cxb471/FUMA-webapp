#!/usr/bin/perl

###########################################################
# eQTL file has to follow the following structure and tabixable
# chr	pos 	ref	alt(tested)	gene	t/z	p	FDR(if applicable)
#
# matched with chr:pos:alt as alt alleles are assumed to be effect alleles
###########################################################

use strict;
use warnings;
use Config::Simple;
use File::Basename;

die "ERROR: not enough arguments\nUSAGE: ./geteQTL.pl <filedir>\n" if(@ARGV <1);

#config
my $dir = dirname(__FILE__);
my $cfg = new Config::Simple($dir.'/app.config');
my $gtexdir = $cfg->param('data.GTEx');
my $qtldir = $cfg->param('data.QTL');

#get input arguments
my $filedir = $ARGV[0];
$filedir .= '/' unless($filedir=~/\/$/);
my $params = new Config::Simple($filedir.'params.config');
my $tsall = $params->param('eqtlMap.eqtlMaptss');
my $sigonly = $params->param('eqtlMap.eqtlMapSig');
my $eqtlP = $params->param('eqtlMap.eqtlMapP');

#files
my $snpfile = $filedir."snps.txt";
my $out = $filedir."eqtl.txt";

#tissues
my @ts;
my @tempts = split(/:/, $tsall);
my $all = 0;
foreach my $t (@tempts){
	if($t eq "all"){
		$all = 1;
		last;
	}
}
if($all==1){
	my @temp = `ls $gtexdir/*.sig.txt.gz`;
	chomp @temp;
	foreach my $f (@temp){
		$f =~ /$gtexdir\/(.+)\.sig\.txt\.gz/;
		push @ts, "GTEx_".$1;

	}
	push @ts, "BloodeQTL_BloodeQTL";
	push @ts, "BIOSQTL_BIOS_eQTL_geneLevel";
}else{
	@ts = split(/:/, $tsall);
}
my %db;
foreach (@ts){
	/(^.+?)_(.+)/;
	my $s = $1;
	my $f = $2.".txt.gz";
	if(exists $db{$s}){
			$db{$s} .=":".$f;
	}else{
		$db{$s} = $f;
	}
}

my $dist=500000;

my %SNPs;
my %Loci;
my $lid = 0;
open(IN, "$snpfile") or die "Cannot opne $snpfile\n";
<IN>;
while(<IN>){
	my @line = split(/\s/, $_);
	my $id = join(":", ($line[2], $line[3], sort($line[4], $line[5])));
	if($lid == 0){
		$lid++;
		$Loci{$lid}{"chr"}=$line[2];
		$Loci{$lid}{"start"}=$line[3];
		$Loci{$lid}{"end"}=$line[3];
		$SNPs{$lid}{$id}{"pos"}=$line[3];
	}elsif($Loci{$lid}{"chr"}==$line[2] && $line[3]-$Loci{$lid}{"end"} <= $dist){
		$Loci{$lid}{"end"}=$line[3];
		$SNPs{$lid}{$id}{"pos"}=$line[3];
	}else{
		$lid++;
		$Loci{$lid}{"chr"}=$line[2];
		$Loci{$lid}{"start"}=$line[3];
		$Loci{$lid}{"end"}=$line[3];
		$SNPs{$lid}{$id}{"pos"}=$line[3];
	}
}
close IN;
open(OUT, ">$out") or die "Cannot open $out\n";
print OUT "uniqID\tdb\ttissue\tgene\ttestedAllele\tp\ttz\tFDR\n";

foreach my $s (keys %db){
	my @files = split(/:/, $db{$s});
	if($s eq "GTEx"){
		foreach my $f (@files){
			my $file = "$gtexdir/".$f;
			$f =~ /(.+)\.txt.gz/;
			my $ts = $1;
			my $f2 = $ts.".sig.txt.gz";
			my $file2 = "$gtexdir/".$f2;
			foreach my $lid (sort {$a<=>$b} keys %Loci){
				my $chr = $Loci{$lid}{"chr"};
				my $start = $Loci{$lid}{"start"};
				my $end = $Loci{$lid}{"end"};
				if($sigonly){
					my @eqtlsig = split(/\n/, `tabix $file2 $chr:$start-$end`);
					my %sig;
					foreach my $l (@eqtlsig){
						my @line = split(/\s/, $l);
						my $id = join(":", ($line[0], $line[1], sort($line[2], $line[3])));
						print OUT "$id\t$s\t$ts\t$line[4]\t$line[3]\t$line[6]\t$line[5]\t$line[7]\n" if(exists $SNPs{$lid}{$id});
					}
				}else{
					my @eqtlsig = split(/\n/, `tabix $file2 $chr:$start-$end`);
					my %sig;
					foreach my $l (@eqtlsig){
						my @line = split(/\s/, $l);
						my $id = join(":", ($line[0], $line[1], sort($line[2], $line[3])));
						$sig{$id}{$line[4]}=$line[7] if(exists $SNPs{$lid}{$id});
					}
					my @eqtl = split(/\n/, `tabix $file $chr:$start-$end`);
					foreach my $l (@eqtl){
						my @line = split(/\s/, $l);
						next if($line[6]>$eqtlP);
						my $id = join(":", ($line[0], $line[1], sort($line[2], $line[3])));
						if(exists $SNPs{$lid}{$id}){
							$line[4] =~ s/(ENSG\d+).\d+/$1/;
							print OUT "$id\t$s\t$ts\t$line[4]\t$line[3]\t$line[6]\t$line[5]\t";
							if(exists $sig{$id}{$line[4]}){print OUT $sig{$id}{$line[4]}, "\n"}
							else{print OUT "NA\n"}
						}
					}
				}
			}
		}
	}else{
		foreach my $f (@files){
			$f =~ /(.+)\.txt.gz/;
			my $ts = $1;
			my $file = "$qtldir/".$s."/".$f;
			foreach my $lid (sort {$a<=>$b} keys %Loci){
				my $chr = $Loci{$lid}{"chr"};
				my $start = $Loci{$lid}{"start"};
				my $end = $Loci{$lid}{"end"};
				my @eqtl = split(/\n/, `tabix $file $chr:$start-$end`);
				foreach my $l (@eqtl){
					my @line = split(/\s/, $l);
					if($sigonly){next if($line[7]>0.05)}
					else{next if($line[6]>$eqtlP)}
					my $id = join(":", $line[0], $line[1], sort($line[2], $line[3]));
					if(exists $SNPs{$lid}{$id}){
						if($s eq "BRAINEAC"){
							print OUT join("\t", ($id, $s, $ts, $line[4], "NA", $line[6], $line[5], $line[7])), "\n";
							#tested allele was not defined in the original file of BRAINEAC
						}else{
							print OUT join("\t", ($id, $s, $ts, $line[4], $line[3], $line[6], $line[5], $line[7])), "\n";
						}
					}
				}
			}
		}
	}

}
close OUT;

system "Rscript $dir/align_eqtl.R $filedir";
