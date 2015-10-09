#!/usr/bin/perl

#TODO: llevar esto a otro .pl
sub contains{
	$value=pop(@_);
	if( grep{ $_ eq $value} @_ ){
		return 1;
	}else{
		return 0;	
	}
}

sub isInitialized{
	
	return 1;
}

sub isAlreadyRunning{
	$counter = `ps -a | grep -c 'AFLIST'`;
	#$counterIfIsNotRunning = 2; #Linux
	$counterIfIsNotRunning = 3; #MAC
	if($counter > $counterIfIsNotRunning){
		return 1;
	}else{
		return 0;
	}

}

sub showHelp{
	print("ayuda");
}

sub showStatisticsMenu{
	system("clear");
	print("\n---------------------BUSQUEDA DE ESTADISTICAS---------------------\n\n");
	print("1. Buscar estadisticas de centrales...\n");
	print("2. Buscar estadisticas de oficinas...\n");
	print("3. Buscar estadisticas de agentes...\n");
	print("4. Buscar estadisticas de destinos...\n");
	print("5. Ver el ranking de umbrales.\n");
	print("6. Salir de este menu.\n");
	print("\n\nIngrese una consulta: ");
}

sub showRegisterFiltersMenu{
	system("clear");
	print("\n-----------------------FILTROS DE BUSQUEDA-----------------------\n\n");
	print("1. Filtrar por central (una, varias, todas)\n");
	print("2. Filtrar por agente (uno, varios, todos)\n");
	print("3. Filtrar por umbral (uno, varios, todos)\n");
	print("4. Filtrar por tipo de llamada (una, varias, todas)\n");
	print("5. Filtrar por tiempo de conversacion (rango)\n");
	print("6. Filtrar por numero (area y numero de linea) (uno, varios, todos)\n");
	print("7. No ingresar mas filtros");
	print("\n\nIngrese un filtro: ");
}

sub filterRegistersByCentrals{
	system("clear");
	print("Ingrese los identificadores de las centrales separados por una coma (\",\")");
	$input = <STDIN>;
	chomp($input);
	@centrals = split /,/, $input;
	print("centrales ingresadas: @centrals\n");
	$input = <STDIN>;
	return \@centrals;
}

sub filterRegistersByAgents{

	system("clear");
	print("Ingrese los identificadores de los agentes separados por una coma (\",\")");
	$input = <STDIN>;
	chomp($input);
	my @agents = split /,/, $input;
	print("agentes ingresados: @agents\n");
	$input = <STDIN>;
	return \@agents;
}

sub filterRegistersByUmbral{
	system("clear");
	print("Ingrese los identificadores de los umbrales separados por una coma (\",\")");
	$input = <STDIN>;
	chomp($input);
	my @umbral = split /,/, $input;
	print("umbrales ingresados: @umbral\n");
	$input = <STDIN>;
	return \@umbral;
}

sub filterRegistersByType{
	system("clear");
	print("Ingrese los identificadores de los tipos de llamadas separados por una coma (\",\")");
	$input = <STDIN>;
	chomp($input);
	my @types = split /,/, $input;
	print("tipos de llamada ingresados: @types\n");
	$input = <STDIN>;
	return \@types;
}

sub filterRegistersByTime{
	system("clear");
	print("filterRegistersByTime");
	$input = <STDIN>;
}

sub filterRegistersByNumber{
	system("clear");
	print("filterRegistersByNumber");
	$input = <STDIN>;
}



sub loadRegisterFilters{

	my %registerFiltersHash;

	# my @emptyLisy = ();

	# $registerFiltersHash{"centrals"} = \@emptyLisy;
	# $registerFiltersHash{"agents"} = \@emptyLisy;
	# $registerFiltersHash{"unmbrals"} = \@emptyLisy;
	# $registerFiltersHash{"types"} = \@emptyLisy;
	# $registerFiltersHash{"times"} = \@emptyLisy;
	# $registerFiltersHash{"numbers"} =  \@emptyLisy;


	$filter = '0';
	while($filter != '7'){
		showRegisterFiltersMenu();
		$filter = <STDIN>;
		chomp($filter);
		if ($filter == 1) {
			$registerFiltersHash{"centrals"} = filterRegistersByCentrals();
		}
		if ($filter == 2) {
			$registerFiltersHash{"agents"} = filterRegistersByAgents();
		}
		if ($filter == 3) {
			$registerFiltersHash{"umbrals"} = filterRegistersByUmbral();
		}
		if ($filter == 4) {
			$registerFiltersHash{"types"} = filterRegistersByType();
		}
		if ($filter == 5) {
			$registerFiltersHash{"times"} = filterRegistersByTime();
		}
		if ($filter == 6) {
			$registerFiltersHash{"numbers"} = filterRegistersByNumber();
		}
	}
	#@centrals = @{$registerFiltersHash{"centrals"}};
	#print("hash{centrals} = @centrals\n");
	return %registerFiltersHash;
}

sub loadInputFiles{
	%h = @_;
	$range = $h{"range"};
	@offices = @{$h{"offices"}};
	$numberOfOffices = @offices;
	#print("num = $numberOfOffices\n");
	#print("offices: @offices\n");
	#print("range: $range\n");
	@list;
	$dirname = "../PROCDIR";
	opendir ( DIR, $dirname );
	while( $filename = readdir(DIR)){
		if ($filename =~ /[^_]_[0-9]{6}/){
			@params = split /_/, $filename;
			@dates = split /-/, $range;
			if ($params[1] >= $dates[0] and $params[1] <= $dates[1]){
				if (($numberOfOffices == 0) or (contains(@offices, $params[0]))) {
					push(@list, "../PROCDIR/$filename");
				}

				
			}
		}
	}
	closedir(DIR);
	$dirname = "../REPODIR";
	opendir ( DIR, $dirname );
	while( $filename = readdir(DIR)){
		if ($filename =~ /subllamadas\.[0-9]{3}/){
				push(@list, "../REPODIR/$filename");
		}
	}
	closedir(DIR);
	return @list;
}

sub isRange{
	return (@_[0] =~ /[0-9]{4}[0-9]{2}-[0-9]{4}[0-9]{2}/);
}

sub loadInputFilesFilters{
	system("clear");
	print("Debe ingresar un rango de fechas para los archivos de entrada\n\tcon el formato AAAAMM-AAAAMM.\n");
	print("\tPor ejemplo: \"201501-201512\" representa todo el 2015\n");
	$range = "";
	while(not isRange($range)){
		print("Escriba aqui un rango valido: ");
		$range = <STDIN>;
		chomp($range);
	}
	%hash;
	$hash{"range"} = $range;

	print("\n\nDebe ingresar una lista de oficinas para filrar los archivos de entrada\n\tseparados por \",\".\n");
	print("\tPor ejemplo: \"DE1,NOP\"\n");
	print("\tEscriba aqui la lista de oficinas: ");	
	$line = <STDIN>;
	chomp($line);
	@offices = split /,/, $line;


	%hash;
	$hash{"range"} = $range;
	$hash{"offices"} = \@offices;
 	
 	#$offices2 = $hash{"offices"};
 	#print("offices2: $offices2->[0]\n");

	#print "@{[%hash]}";

	return %hash;
}

sub main{
	if ( not(isInitialized) ) {
		print("No esta realizada la inicializacion de ambiente\n");
		return 1;
	}
	if ( isAlreadyRunning ) {
		print("Ya hay un AFLIST corriendo\n");
		return 1;
	}
	if (contains(@ARGV, "-h")) {
		showHelp();
		return 0;
	}
	if (contains(@ARGV, "-r")) {
		%fileFiltersHash = loadInputFilesFilters();
		@inputFiles = loadInputFiles(%fileFiltersHash);
		#print("inputs: @inputFiles\n");
		#$inputWaiter = <STDIN>;
		%registerFiltersHash = loadRegisterFilters();
		printRegisterFilters(%registerFiltersHash);
		processFiles(\@inputFiles, \%registerFiltersHash);
	}
	if (contains(@ARGV, "-s")) {
		%fileFiltersHash = loadInputFilesFilters();
		@inputFiles = loadInputFiles(%fileFiltersHash);
		my $fileHdl;
		my %hashCentralsCalls;
		my %hashOfficesCalls;
		my %hashAgentsCalls;
		my %hashDestinationsCalls;
		my %hashUmbralsCalls;
		#print("files: @inputFiles\n");
		#$in = <STDIN>;
		foreach my $fileName (@inputFiles){
			my @params = split /_/, $fileName;
			$office = $params[0];
			open ($fileHdl,"<", $fileName) or die "no se puede abrir $file: $!";
			while (my $linea=<$fileHdl>) {
				@tokens = split /;/, $linea;
				
				if (exists($hashCentralsCalls{$tokens[0]})){
					$hashCentralsCalls{$tokens[0]} = $hashCentralsCalls{$tokens[0]} + 1;
				}else{
					$hashCentralsCalls{$tokens[0]} = 1;
				}
				
				if (exists($hashOfficesCalls{$office})){
					$hashOfficesCalls{$office} = $hashOfficesCalls{$office} + 1;
				}else{
					$hashOfficesCalls{$office} = 1;
				}

				if (exists($hashAgentsCalls{$tokens[1]})){
					$hashAgentsCalls{$tokens[1]} = $hashAgentsCalls{$tokens[1]} + 1;
				}else{
					$hashAgentsCalls{$tokens[1]} = 1;
				}


				if (exists($hashDestinationsCalls{$tokens[10]})){
					$hashDestinationsCalls{$tokens[10]} = $hashDestinationsCalls{$tokens[10]} + 1;
				}else{
					$hashDestinationsCalls{$tokens[10]} = 1;
				}

				if (exists($hashUmbralsCalls{$tokens[2]})){
					$hashUmbralsCalls{$tokens[2]} = $hashUmbralsCalls{$tokens[2]} + 1;
				}else{
					$hashUmbralsCalls{$tokens[2]} = 1;
				}
			}			
			close ($fileHdl);
		}
		showStatisticsMenu();
		my $querry = <STDIN>;
		while($querry != '6'){

			if ( $querry == 1 ){
				#FALTA MOSTRAR DETALLES DE LA CENTRAL, ARMARSE UN HASH CON EL ARCHIVO MAE AL PPIO Y LISTO
				print("Si desea ver la central con mayor cantidad de llamadas sospechosas, ingrese 1.\nSi desea ver el ranking de centrales, ingrese 2.\n");
				my $op = <STDIN>;
				if ($op == 1){
					foreach my $call (sort { -($hashCentralsCalls{$a} <=> $hashCentralsCalls{$b}) } keys %hashCentralsCalls) { 
			       		print("Central con mayor cantidad de llamadas sospechosas: $call: $hashCentralsCalls{$call}\n");
						last;
	    			}	
	    		}else{
	    			if ($op == 2){
	    				print("Ranking de centrales:\n");
	    				my $counter = 1;
						foreach my $call (sort { -($hashCentralsCalls{$a} <=> $hashCentralsCalls{$b}) } keys %hashCentralsCalls) {
					    	print("$counter: $call ($hashCentralsCalls{$call})\n");
		    				++$counter;
		    			}

	    			}else{
	    				print("La opcion ingresada no es valida\n");
	    			}
	    		}
			}
			if ( $querry == 2 ){
			    print("Si desea ver la oficina con mayor cantidad de llamadas sospechosas, ingrese 1.\nSi desea ver el ranking de oficinas, ingrese 2.\n");
				my $op = <STDIN>;
				if ($op == 1){
					foreach my $call (sort { -($hashOfficesCalls{$a} <=> $hashOfficesCalls{$b}) } keys %hashOfficesCalls) { 
			       		print("Oficina con mayor cantidad de llamadas sospechosas: $call: $hashOfficesCalls{$call}\n");
						last;
	    			}	
	    		}else{
	    			if ($op == 2){
	    				print("Ranking de oficinas:\n");
	    				my $counter = 1;
						foreach my $call (sort { -($hashOfficesCalls{$a} <=> $hashOfficesCalls{$b}) } keys %hashOfficesCalls) {
					    	print("$counter: $call ($hashOfficesCalls{$call})\n");
		    				++$counter;
		    			}

	    			}else{
	    				print("La opcion ingresada no es valida\n");
	    			}
	    		}
			}
			if ( $querry == 3 ){
				print("Si desea ver al agente con mayor cantidad de llamadas sospechosas, ingrese 1.\nSi desea ver el ranking de agentes, ingrese 2.\n");
				my $op = <STDIN>;
				if ($op == 1){
					foreach my $call (sort { -($hashAgentsCalls{$a} <=> $hashAgentsCalls{$b}) } keys %hashAgentsCalls) { 
			       		print("Agente con mayor cantidad de llamadas sospechosas: $call: $hashAgentsCalls{$call}\n");
						last;
	    			}	
	    		}else{
	    			if ($op == 2){
	    				print("Ranking de agentes:\n");
	    				my $counter = 1;
						foreach my $call (sort { -($hashAgentsCalls{$a} <=> $hashAgentsCalls{$b}) } keys %hashAgentsCalls) {
					    	print("$counter: $call ($hashAgentsCalls{$call})\n");
		    				++$counter;
		    			}

	    			}else{
	    				print("La opcion ingresada no es valida\n");
	    			}
	    		}
			}
			if ( $querry == 4 ){
				print("Si desea ver el destino con mayor cantidad de llamadas sospechosas, ingrese 1.\nSi desea ver el ranking de destinos, ingrese 2.\n");
				my $op = <STDIN>;
				if ($op == 1){
					foreach my $call (sort { -($hashDestinationsCalls{$a} <=> $hashDestinationsCalls{$b}) } keys %hashDestinationsCalls) { 
			       		print("Destino con mayor cantidad de llamadas sospechosas: $call: $hashDestinationsCalls{$call}\n");
						last;
	    			}	
	    		}else{
	    			if ($op == 2){
	    				print("Ranking de destinos:\n");
	    				my $counter = 1;
						foreach my $call (sort { -($hashDestinationsCalls{$a} <=> $hashDestinationsCalls{$b}) } keys %hashDestinationsCalls) {
					    	print("$counter: $call ($hashDestinationsCalls{$call})\n");
		    				++$counter;
		    			}

	    			}else{
	    				print("La opcion ingresada no es valida\n");
	    			}
	    		}
			}
			if ( $querry == 5 ){
				print("Ranking de umbrales (se ignoran los umbrales con una sola llamada sospechosa):\n");
				my $counter = 1;
			    foreach my $call (sort { -($hashUmbralsCalls{$a} <=> $hashUmbralsCalls{$b}) } keys %hashUmbralsCalls) { 
		       		if ($hashUmbralsCalls{$call} > 1){
		       			print("$counter: $call ($hashUmbralsCalls{$call})");	
		       		}
		       		++$counter;
    			}
			}
			$in = <STDIN>;
			showStatisticsMenu();
			$querry = <STDIN>;
		}
	}
}

sub printRegisterFilters{
	%registerFiltersHash = @_;
	my @centrals = @{$registerFiltersHash{"centrals"}};
	my @agents = @{$registerFiltersHash{"agents"}};
	my @umbrals = @{$registerFiltersHash{"umbrals"}};
	my @types = @{$registerFiltersHash{"types"}};

	print("Filtros Que Se Utilizaran:\n");
	print("hash{centrals} = @centrals\n");
	print("hash{agents} = @agents\n");
	print("hash{umbrals} = @umbrals\n");
	print("hash{types} = @types\n");

	

	

	$input = <STDIN>;
}

sub processFiles{
	my ($inputFilesRef, $registerFiltersHashRef) = @_;
	my @files = @$inputFilesRef;
	my %filters = %$registerFiltersHashRef;
	#print("inputFiles = @files\n");
	my @centrals = @{$filters{"centrals"}};
	my $centralSize= scalar @centrals;

	my @agents = @{$filters{"agents"}};
	my $agentsSize= scalar @agents;

	my @umbrals = @{$filters{"umbrals"}};
	my $umbralsSize= scalar @umbrals;

	my @types = @{$filters{"types"}};
	my $typesSize= scalar @types;

	

	#print("centrals @centrals\n");
	#print "central size: $centralSize";

	my $fileHdl;
	foreach my $file (@files){
		open ($fileHdl,"<", $file) or die "no se puede abrir $file: $!";
		while (my $linea=<$fileHdl>) {
			@tokens = split /;/, $linea;
			if (not (  contains(@centrals, $tokens[0]) or $centralSize==0)){
				next;
			}
			if (not (  contains(@agents, $tokens[1]) or $agentsSize==0)){
				next;
			}
			if (not (  contains(@umbrals, $tokens[2]) or $umbralsSize==0)){
				next;
			}
			if (not (  contains(@types, $tokens[3]) or $typesSize==0)){
				next;
			}
			


			print $linea;
		}
		close ($fileHdl);
	}
}


main();
