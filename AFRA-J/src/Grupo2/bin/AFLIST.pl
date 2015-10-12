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
	$REPODIR=$ENV{'REPODIR'};
	$PROCDIR=$ENV{'PROCDIR'};
	$MAEDIR=$ENV{'MAEDIR'};
	if ("$REPODIR" and "$PROCDIR"){
		return 1;	
	}else{
		return 0;
	}
	
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
	print("Debe ingresar un rango de tiempo de llamada con el formato sec-sec.\n");
	print("\tPor ejemplo: \"10-134\" representa desde 10 segundos hasta 134\n");
	my $range = "";
	while(not isRangeCallTime($range)){
		print("Escriba aqui un rango valido: ");
		$range = <STDIN>;
		chomp($range);
	}
	print("tiempo de llamada ingresados: $range\n");
	$input = <STDIN>;

	return \$range;

}

sub filterRegistersByNumber{
	system("clear");
	print("Ingrese los numeros con Codigo de Area y luego el numero separado por un (\"-\") y los distintos numeros por (\",\")");
	print("\tPor ejemplo: \"11-43432211,299-47933716\" representa area 11 numero 43432211\n");
	$input = <STDIN>;
	chomp($input);
	my @numbers = split /,/, $input;
	print("numeros ingresados: @numbers\n");
	$input = <STDIN>;
	return \@numbers;
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
	$opFiles = $h{"typeOfFiles"};
	$numberOfOffices = @offices;
	#print("num = $numberOfOffices\n");
	#print("offices: @offices\n");
	#print("range: $range\n");
	@list;
	if($opFiles == 2){
		$dirname = "$PROCDIR";
	#	$dirname = "../PROCDIR";

		opendir ( DIR, $dirname );
		while( $filename = readdir(DIR)){
			if ($filename =~ /[^_]_[0-9]{6}/){
				@params = split /_/, $filename;
				@dates = split /-/, $range;
				if ($params[1] >= $dates[0] and $params[1] <= $dates[1]){
					if (($numberOfOffices == 0) or (contains(@offices, $params[0]))) {
						push(@list, "$PROCDIR/$filename");
					}

					
				}
			}
		}
		closedir(DIR);
	}
	if($opFiles == 1){
		#$dirname = "$REPODIR";
		$dirname = "../REPODIR";
		opendir ( DIR, $dirname );
		while( $filename = readdir(DIR)){
			if ($filename =~ /subllamadas\.[0-9]{3}/){
					push(@list, "$REPODIR/$filename");
			}
		}
	}
	closedir(DIR);
	return @list;
}

sub isRange{
	return (@_[0] =~ /[0-9]{4}[0-9]{2}-[0-9]{4}[0-9]{2}/);
}

sub isRangeCallTime{
	return (@_[0] =~ /^[0-9]*-[0-9]*$/);
}

sub loadInputFilesFilters{
	system("clear");
	
	print("Si desea que los archivos de entrada sean los filtrados con anterioridad por AFLIST, ingrese 1\nSi desea tomar los creados en los comandos anteriores Ingrese 2\n");
	$opFiles = <STDIN>;
	 
	while($opFiles != 1 and $opFiles != 2){
		print("Por favor, ingrese una opcion valida: ");
		$opFiles = <STDIN>;
	}
	
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
	$hash{"typeOfFiles"} = $opFiles;	
 	
 	#$offices2 = $hash{"offices"};
 	#print("offices2: $offices2->[0]\n");

	#print "@{[%hash]}";

	return %hash;
}

sub loadCentralsFile{
	my %hash;
	my $fileHdl;
	my $fileName = "$MAEDIR/centrales.csv";
	open ($fileHdl,"<", $fileName) or die "no se puede abrir $fileName: $!";
	while (my $line=<$fileHdl>){
		chomp($line);
		my @tokens = split /;/, $line;
		$hash{$tokens[0]} = $tokens[1];
	}
	close ($fileHdl);
	return %hash;
}

sub loadAreasFile{
	my %hash;
	my $fileHdl;
	my $fileName = "$MAEDIR/CdP.csv";
	open ($fileHdl,"<", $fileName) or die "no se puede abrir $fileName: $!";
	while (my $line=<$fileHdl>){
		chomp($line);
		my @tokens = split /;/, $line;
		my $codInHash = -$tokens[0];
		$hash{$codInHash} = $tokens[1];
	}
	close ($fileHdl);

	my $fileName = "$MAEDIR/CdA.csv";
	open ($fileHdl,"<", $fileName) or die "no se puede abrir $fileName: $!";
	while (my $line=<$fileHdl>){
		chomp($line);
		my @tokens = split /;/, $line;
		$hash{$tokens[1]} = $tokens[0];
	}
	close ($fileHdl);
	return %hash;	
}

sub loadOfficesFromAgents{
	my %hash;
	my $fileHdl;
	my $fileName = "$MAEDIR/agentes.csv";
	open ($fileHdl,"<", $fileName) or die "no se puede abrir $fileName: $!";
	while (my $line=<$fileHdl>){
		chomp($line);
		my @tokens = split /;/, $line;
		my $agent = "$tokens[2]";
		$hash{$agent} = $tokens[3];
	}
	close ($fileHdl);
	return %hash;	
}

sub loadEmails{
	my %hash;
	my $fileHdl;
	my $fileName = "$MAEDIR/agentes.csv";
	open ($fileHdl,"<", $fileName) or die "no se puede abrir $fileName: $!";
	while (my $line=<$fileHdl>){
		chomp($line);
		my @tokens = split /;/, $line;
		my $agent = "$tokens[2]";
		$hash{$agent} = $tokens[4];
	}
	close ($fileHdl);
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

	if (contains(@ARGV, "-r")) {

		if (contains(@ARGV, "-h")) {
			showHelpR();
			return 0;
		}

		%fileFiltersHash = loadInputFilesFilters();
		@inputFiles = loadInputFiles(%fileFiltersHash);
		#print("inputs: @inputFiles\n");
		#$inputWaiter = <STDIN>;
		%registerFiltersHash = loadRegisterFilters();
		printRegisterFilters(%registerFiltersHash);
		processFiles(\@inputFiles, \%registerFiltersHash);
	}
	if (contains(@ARGV, "-s")) {


		if (contains(@ARGV, "-h")) {
			showHelpS();
			return 0;
		}

		%centralsById = loadCentralsFile();
		%areasById = loadAreasFile();
		%officesByAgents = loadOfficesFromAgents();
		%emails = loadEmails();
		%fileFiltersHash = loadInputFilesFilters();
		@inputFiles = loadInputFiles(%fileFiltersHash);
		my $fileHdl;
		my %hashCentralsCalls;
		my %hashCentralsCallsInSeconds;
		my %hashOfficesCalls;
		my %hashOfficesCallsInSeconds;
		my %hashAgentsCalls;
		my %hashAgentsCallsInSeconds;
		my %hashAreasCalls;
		my %hashUmbralsCalls;
		#print("files: @inputFiles\n");
		#$in = <STDIN>;
		foreach my $fileName (@inputFiles){
			my @params = split /_/, $fileName;
			my @path = split /\//, $params[0];
			$office = pop(@path);
			open ($fileHdl,"<", $fileName) or die "no se puede abrir $fileName: $!";
			while (my $linea=<$fileHdl>) {
				@tokens = split /;/, $linea;
				my $numberOfTokens = scalar @tokens;
				if($numberOfTokens > 12){
					$office = $tokens[12];
				}


				if (exists($hashCentralsCalls{$tokens[0]})){
					$hashCentralsCalls{$tokens[0]} = $hashCentralsCalls{$tokens[0]} + 1;
					$hashCentralsCallsInSeconds{$tokens[0]} = $hashCentralsCallsInSeconds{$tokens[0]} + $tokens[5];
				}else{
					$hashCentralsCalls{$tokens[0]} = 1;
					$hashCentralsCallsInSeconds{$tokens[0]} = $tokens[5];
				}
				
				if (exists($hashOfficesCalls{$office})){
					$hashOfficesCalls{$office} = $hashOfficesCalls{$office} + 1;
					$hashOfficesCallsInSeconds{$office} = $hashOfficesCallsInSeconds{$office} + $tokens[5];
				}else{
					$hashOfficesCalls{$office} = 1;
					$hashOfficesCallsInSeconds{$office} = $tokens[5];
				}

				if (exists($hashAgentsCalls{$tokens[1]})){
					$hashAgentsCalls{$tokens[1]} = $hashAgentsCalls{$tokens[1]} + 1;
					$hashAgentsCallsInSeconds{$tokens[1]} = $hashAgentsCallsInSeconds{$tokens[1]} + $tokens[5];
				}else{
					$hashAgentsCalls{$tokens[1]} = 1;
					$hashAgentsCallsInSeconds{$tokens[1]} = $tokens[5];
				}

				if ($tokens[8] == ""){ #si es local
					if (exists($hashAreasCalls{$tokens[9]})){
						$hashAreasCalls{$tokens[9]} = $hashAreasCalls{$tokens[9]} + 1;
					}else{
						$hashAreasCalls{$tokens[9]} = 1;
					}
				}else{	#si es al exterior, va el codigo de pais, pero negativo
					if (exists($hashAreasCalls{-$tokens[8]})){
						$hashAreasCalls{-$tokens[8]} = $hashAreasCalls{-$tokens[8]} + 1;
					}else{
						$hashAreasCalls{-$tokens[8]} = 1;
					}
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
				print("Si desea ver la central mas sospechada, ingrese 1.\nSi desea ver el ranking de centrales, ingrese 2.\n");
				my $op = <STDIN>;
				print("Si desea que el ranking se calcule por cantidad de llamadas sospechosas, ingrese 1.\nSi desea que se calcule por acumulacion de tiempo, ingrese 2\n");
				my $op2 = <STDIN>;
				if ($op2 == 1){
					if ($op == 1){
						foreach my $call (sort { -($hashCentralsCalls{$a} <=> $hashCentralsCalls{$b}) } keys %hashCentralsCalls) { 
				       		print("Central con mayor cantidad de llamadas sospechosas: $call -> $centralsById{$call} ($hashCentralsCalls{$call} llamadas).\n");
							last;
		    			}	
		    		}else{
		    			if ($op == 2){
		    				print("Ranking de centrales:\n");
		    				my $counter = 1;
							foreach my $call (sort { -($hashCentralsCalls{$a} <=> $hashCentralsCalls{$b}) } keys %hashCentralsCalls) {
						    	print("$counter: $call -> $centralsById{$call} ($hashCentralsCalls{$call} llamadas)\n");
			    				++$counter;
			    			}

		    			}else{
		    				print("La opcion ingresada no es valida\n");
		    			}
		    		}
		    	}else{
		    		if ($op2 == 2){
			    		if ($op == 1){
							foreach my $call (sort { -($hashCentralsCallsInSeconds{$a} <=> $hashCentralsCallsInSeconds{$b}) } keys %hashCentralsCallsInSeconds) { 
					       		print("Central con mayor cantidad de segundos en llamadas sospechosas: $call -> $centralsById{$call} ($hashCentralsCallsInSeconds{$call} segundos).\n");
								last;
			    			}	
			    		}else{
			    			if ($op == 2){
			    				print("Ranking de centrales:\n");
			    				my $counter = 1;
								foreach my $call (sort { -($hashCentralsCalls{$a} <=> $hashCentralsCalls{$b}) } keys %hashCentralsCalls) {
							    	print("   $counter: $call -> $centralsById{$call} ($hashCentralsCallsInSeconds{$call} segundos)\n");
				    				++$counter;
				    			}

			    			}else{
			    				print("La opcion ingresada no es valida\n");
			    			}
			    		}
	    			}else{
	    				print("La opcion ingresada no es valida\n");
	    			}
		    	}
			}
			if ( $querry == 2 ){
			    print("Si desea ver la oficina mas sospechada, ingrese 1.\nSi desea ver el ranking de oficinas, ingrese 2.\n");
				my $op = <STDIN>;
				print("Si desea que el ranking se calcule por cantidad de llamadas sospechosas, ingrese 1.\nSi desea que se calcule por acumulacion de tiempo, ingrese 2\n");
				my $op2 = <STDIN>;
				if ($op2 == 1){
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
		    	}else{
		    		if($op2 == 2){
		    			if ($op == 1){
							foreach my $call (sort { -($hashOfficesCallsInSeconds{$a} <=> $hashOfficesCallsInSeconds{$b}) } keys %hashOfficesCallsInSeconds) { 
					       		print("Oficina con mayor cantidad de segundos en llamadas sospechosas: $call ($hashOfficesCallsInSeconds{$call} segundos)\n");
								last;
			    			}	
			    		}else{
			    			if ($op == 2){
			    				print("Ranking de oficinas:\n");
			    				my $counter = 1;
								foreach my $call (sort { -($hashOfficesCallsInSeconds{$a} <=> $hashOfficesCallsInSeconds{$b}) } keys %hashOfficesCallsInSeconds) {
							    	print("$counter: $call ($hashOfficesCallsInSeconds{$call} segundos)\n");
				    				++$counter;
				    			}

			    			}else{
			    				print("La opcion ingresada no es valida\n");
			    			}
			    		}
		    		}else{
		    			print("La opcion ingresada no es valida\n");
		    		}
		    	}
			}
			if ( $querry == 3 ){
				print("Si desea ver al agente mas sospechado, ingrese 1.\nSi desea ver el ranking de agentes, ingrese 2.\n");
				my $op = <STDIN>;
				print("Si desea que el ranking se calcule por cantidad de llamadas sospechosas, ingrese 1.\nSi desea que se calcule por acumulacion de tiempo, ingrese 2\n");
				my $op2 = <STDIN>;
				if ($op2 == 1){
					if ($op == 1){
						foreach my $call (sort { -($hashAgentsCalls{$a} <=> $hashAgentsCalls{$b}) } keys %hashAgentsCalls) { 
				       		my $email = lc $emails{$call};
				       		print("Agente con mayor cantidad de llamadas sospechosas: $call\n   email: $email\n   oficina: $officesByAgents{$call}\n");
							last;
		    			}	
		    		}else{
		    			if ($op == 2){
		    				print("Ranking de agentes:\n");
		    				my $counter = 1;
							foreach my $call (sort { -($hashAgentsCalls{$a} <=> $hashAgentsCalls{$b}) } keys %hashAgentsCalls) {
								my $email = lc $emails{$call};
						    	print("   $counter: $call ($hashAgentsCalls{$call} llamadas)\n      email: $email\n      oficina: $officesByAgents{$call}\n");
			    				++$counter;
			    			}

		    			}else{
		    				print("La opcion ingresada no es valida\n");
		    			}
		    		}
	    		}else{
	    			if ($op2 == 2){
	    				if ($op == 1){
							foreach my $call (sort { -($hashAgentsCallsInSeconds{$a} <=> $hashAgentsCallsInSeconds{$b}) } keys %hashAgentsCallsInSeconds) { 
					       		my $email = lc $emails{$call};
					       		print("Agente con mayor cantidad de segundos en llamadas sospechosas: $call\n   email: $email\n   oficina: $officesByAgents{$call}\n");
								last;
			    			}	
			    		}else{
			    			if ($op == 2){
			    				print("Ranking de agentes:\n");
			    				my $counter = 1;
								foreach my $call (sort { -($hashAgentsCallsInSeconds{$a} <=> $hashAgentsCallsInSeconds{$b}) } keys %hashAgentsCallsInSeconds) {
									my $email = lc $emails{$call};
							    	print("   $counter: $call ($hashAgentsCallsInSeconds{$call} segundos)\n      email: $email\n      oficina: $officesByAgents{$call}\n");
				    				++$counter;
				    			}

			    			}else{
			    				print("La opcion ingresada no es valida\n");
			    			}
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
					foreach my $call (sort { -($hashAreasCalls{$a} <=> $hashAreasCalls{$b}) } keys %hashAreasCalls) {
						my $destination;
						if ($call < 0){ #llamada al exterior
							$destination = -$call;
						}else{
							$destination = $call;
						}
						print("El destino con mayor cantidad de llamadas sospechosas es $destination -> $areasById{$call}\n");
						last;
	    			}	
	    		}else{
	    			if ($op == 2){
	    				print("Ranking de destinos:\n");
	    				my $counter = 1;
						foreach my $call (sort { -($hashAreasCalls{$a} <=> $hashAreasCalls{$b}) } keys %hashAreasCalls) {
					    	if ($call < 0){ #llamada al exterior
					    		$destination = -$call;
							}else{
								$destination = $call;
							}
							print("   $counter: $destination -> $areasById{$call}\n");
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
		       			print("   $counter: $call ($hashUmbralsCalls{$call} llamadas)\n");	
		       		}
		       		++$counter;
    			}
			}
			$in = <STDIN>;
			showStatisticsMenu();
			$querry = <STDIN>;
		}
	}

	if (contains(@ARGV, "-h")) {
		showHelp();
		return 0;
	}
}

sub printRegisterFilters{
	%registerFiltersHash = @_;
	my @centrals = @{$registerFiltersHash{"centrals"}};
	my @agents = @{$registerFiltersHash{"agents"}};
	my @umbrals = @{$registerFiltersHash{"umbrals"}};
	my $times = ${$registerFiltersHash{"times"}};

	my @numbers = @{$registerFiltersHash{"numbers"}};




	print("Filtros Que Se Utilizaran:\n");
	print("hash{centrals} = @centrals\n");
	print("hash{agents} = @agents\n");
	print("hash{umbrals} = @umbrals\n");
	print("hash{types} = @types\n");
	print("hash{times} = $times\n");
	print("hash{numbers} = @numbers\n");





	

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


	my $times = ${$filters{"times"}};
	my @timesArray = split /-/, $times;

	my @numbers = @{$filters{"numbers"}};
	my $numbersSize= scalar @numbers;


	#print "times: $times";
	#print "times Array: @timesArray";
			
	

	

	#print("centrals @centrals\n");
	#print "central size: $centralSize";

	my $fileHdl;
	foreach my $file (@files){
		open ($fileHdl,"<", $file) or die "no se puede abrir $file: $!";
		while (my $linea=<$fileHdl>) {
			chomp($linea);
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

			if (not (  ($tokens[5] >= $timesArray[0] and $tokens[5] <= $timesArray[1]) or $times==0)){
				next;
			}

			my $areaYNumero = "$tokens[6]-$tokens[7]";

			if (not (  contains(@numbers, $areaYNumero) or $numbersSize==0)){
				next;
			}



			my $numberOfTokens = scalar @tokens;
			if($numberOfTokens > 12){ #ya tiene oficina
				print "$linea\n";
			}else{ #append oficina
				my @params = split /_/, $file;
				my @path = split /\//, $params[0];
				my $office = pop(@path);
				print "$linea;$office\n";
			}
		}
		close ($fileHdl);
	}
}

sub showHelp{
	print("AFLIST\n");
	print("El comando posee dos modos de uso:\n");
	print("\nModo Consulta Llamadas sospechosas (-r): \n");
	print("El Programa permite consultar y filtrar los distintos archivos de llamadas sospchosas\n");
	print("\nModo Estadisticas Llamadas sospechosas (-s): \n");
	print("Sobre el modo de uso, consultar -h -r\n");
	print("Se pueden obtener estadisticas sobre las llamadas sospechosas, como cual es la oficina con mayor cantidad de llamadas sospechosas, etc.\n");
	print("Sobre el modo de uso, consultar -h -s\n");
	print("\nModo Escritura (-w): OPCIONAL\n");
	print("En modo Consulta: el programa escribe el resultado en un archivo de subllamada por ejemplo subllamada.xxx\n");
	print("En modo Estadistica: el programa escribe el resultado en un archivo a eleccion");
}
sub showHelpR{
	print("Consulta Llamadas Sospechosas -r:\n");
	print("Modo de Uso:\n");

	print("Se debe primero elejir si desea utilizar los archivos generados por el comando anterior o los archivos generados por la consulta -r anterior. Para eso seguir el menu interactivo. \n");
	print("Luego se debe proporcionar un rango de aniomes el cual se desea consultar.Ej: 201501-201520\n");
	print("Junto con una lista de  oficinas.Ej: BEL,DE1 \n");
	print("El siguiente paso es agregar distintos filtros.\n");

	print("Utilizando el menu interactivo, completar con los filtros deseados\n");
	print("Se puede encontrar informacion de cada filtro en el mismo menu.\n");
	print("Una vez que se han introducido los filtros deseados, elejir la opcion 7, para salir.\n");
	print("Luego se muestran los filtros aplicados y los resultados en pantalla.\n");	
}

sub showHelpS{
	print("Estadistica Llamadas Sospechosas -s:\n");
	print("Modo de Uso:\n");

	print("Se debe primero elejir si desea utilizar los archivos generados por el comando anterior o los archivos generados por la consulta -r anterior. Para eso seguir el menu interactivo. \n");
	print("Luego se debe proporcionar un rango de aniomes el cual se desea consultar.Ej: 201501-201520\n");
	print("Junto con una lista de  oficinas.Ej: BEL,DE1 \n");
	print("El siguiente paso es agregar distintos filtros.\n");

	print("Luego se debe elejir la busqueda que desea realizar: centrales, oficinas, agentes, etc.\n");
	print("Utilizando el menu interactivo, ingresar la opcion deseada\n");

	print("Una vez que definimos la busqueda, el programa le realizara distinas preguntas, como por ejemplo: rankear por tiempo o cantidad de llamadas, ver la primera o el ranking, etc.\n");
	print("Cuando el usuario elija la opcion 6, para salir. El programa realizara la busqueda seleccionada terminando la ejecucion.\n");

}

main();
