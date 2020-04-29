% adalet veyis turgut
% 2017400210
% compiling: yes
% complete: yes

% artist(ArtistName, Genres, AlbumIds).
% album(AlbumId, AlbumName, ArtistNames, TrackIds).
% track(TrackId, TrackName, ArtistNames, AlbumName, [Explicit, Danceability, Energy,
%                                                    Key, Loudness, Mode, Speechiness,
%                                                    Acousticness, Instrumentalness, Liveness,
%                                                    Valence, Tempo, DurationMs, TimeSignature]).

% getArtistTracks(+ArtistName, -TrackIds, -TrackNames) 5 points
getArtistTracks(ArtistName, TrackIds, TrackNames):-
	findall(X,
		(
		artist(ArtistName,_,AlbumList),
		member(A,AlbumList),
		album(A,_,_,TrackIdList),
		member(X,TrackIdList)
		),
		TrackIds),
	findall(X,
		(
		member(Y,TrackIds),
		track(Y,X,_,_,_)
		),	
		TrackNames).

% albumFeatures(+AlbumId, -AlbumFeatures) 5 points
albumFeatures(AlbumId, AlbumFeatures):-
	album(AlbumId,_,_,TrackIds),
	findall(X,
		(
		member(Track,TrackIds),
		track(Track,_,_,_,A),
		filter_features(A,X)
		),
		FullFeaturesList),
	calculateAverageFeatures(FullFeaturesList,AlbumFeatures).

% artistFeatures(+ArtistName, -ArtistFeatures) 5 points
artistFeatures(ArtistName, ArtistFeatures):-
	getArtistTracks(ArtistName,TrackIds,_),
	findall(X,
		(
		member(Track,TrackIds),
		track(Track,_,_,_,A),
		filter_features(A,X)
		),
		FullFeaturesList),
	calculateAverageFeatures(FullFeaturesList,ArtistFeatures).

% trackDistance(+TrackId1, +TrackId2, -Score) 5 points
trackDistance(TrackId1, TrackId2, Score):-
	track(TrackId1,_,_,_,F1),
	track(TrackId2,_,_,_,F2),
	filter_features(F1,Feature1),
	filter_features(F2,Feature2),
	distanceCalculator(Feature1,Feature2,Score).

% albumDistance(+AlbumId1, +AlbumId2, -Score) 5 points
albumDistance(AlbumId1, AlbumId2, Score):-
	albumFeatures(AlbumId1,Feature1),
	albumFeatures(AlbumId2,Feature2),
	distanceCalculator(Feature1,Feature2,Score).

% artistDistance(+ArtistName1, +ArtistName2, -Score) 5 points
artistDistance(ArtistName1, ArtistName2, Score):-
	artistFeatures(ArtistName1,Feature1),
	artistFeatures(ArtistName2,Feature2),
	distanceCalculator(Feature1,Feature2,Score).

% findMostSimilarTracks(+TrackId, -SimilarIds, -SimilarNames) 10 points
findMostSimilarTracks(TrackId, SimilarIds, SimilarNames):-
	findall([Dist,Id,Name],
		(
		track(Id,Name,_,_,_),
		\+ Id = TrackId,
		trackDistance(TrackId,Id,Dist)
		),
		BigList),
	sort(0,@=<,BigList,Sorted),
	nth0(30,Sorted,[H|_]),
	findall([Id,Name],
		(
		member([Y,Id,Name],Sorted),
		Y<H
		),
		BigListt),
	findall(Id,member([Id,_],BigListt),SimilarIds),
	findall(Name,member([_,Name],BigListt),SimilarNames).
% findMostSimilarAlbums(+AlbumId, -SimilarIds, -SimilarNames) 10 points
findMostSimilarAlbums(AlbumId, SimilarIds, SimilarNames):-
	findall([Dist,Id,Name],
		(
		album(Id,Name,_,_),
		\+ Id = AlbumId,
		albumDistance(AlbumId,Id,Dist)
		),
		BigList),
	sort(0,@=<,BigList,Sorted),
	nth0(30,Sorted,[H|_]),
	findall([Id,Name],
		(
		member([Y,Id,Name],Sorted),
		Y<H
		),
		BigListt),
	findall(Id,member([Id,_],BigListt),SimilarIds),
	findall(Name,member([_,Name],BigListt),SimilarNames).
% findMostSimilarArtists(+ArtistName, -SimilarArtists) 10 points
findMostSimilarArtists(ArtistName, SimilarArtists):-
	findall([Dist,Name],
		(
		artist(Name,_,_),
		\+ Name = ArtistName,
		artistDistance(ArtistName,Name,Dist)
		),
		BigList),
	sort(0,@=<,BigList,Sorted),
	nth0(30,Sorted,[H|_]),
	findall([_,Name],
		(
		member([Y,Name],Sorted),
		Y<H
		),
		BigListt),
	findall(Name,member([_,Name],BigListt),SimilarArtists).

% filterExplicitTracks(+TrackList, -FilteredTracks) 5 points
filterExplicitTracks(TrackList, FilteredTracks):-
	findall(X,
		(
		member(X,TrackList),
		track(X,_,_,_,[E|_]),
		E = 0
		),
		FilteredTracks).

% getTrackGenre(+TrackId, -Genres) 5 points
getTrackGenre(TrackId, Genres):-
	track(TrackId,_,ArtistNames,_,_),
	findall(X,
		(
		member(Artist,ArtistNames),
		artist(Artist,Y,_),
		member(X,Y)
		),
		GenresDuplicatedMaybe),
	list_to_set(GenresDuplicatedMaybe,Genres).

% discoverPlaylist(+LikedGenres, +DislikedGenres, +Features, +FileName, -Playlist) 30 points
discoverPlaylist(LikedGenres, DislikedGenres, Features, FileName, Playlist):-
	findall(X,
		(
		track(X,_,_,_,_),
		getTrackGenre(X,Genres),	
		member(G,Genres),
		member(L,LikedGenres),
		sub_string(G,_,_,_,L)
		),
		Listttt),
	list_to_set(Listttt,Listtt),
	excludeDisliked(Listtt,DislikedGenres,List),
	findall([Dist,Id],
		(
		member(Id,List),
		track(Id,_,_,_,F0),
		filter_features(F0,Filtered),
		distanceCalculator(Filtered,Features,Dist)
		),
		List2),
	sort(0,@=<,List2,Sorted),
	nth0(30,Sorted,[D|_]),
	findall([Id,Dist],
		(
		member([Dist,Id],Sorted),
		Dist<D
		),
		BigList),
	findall(Id,
		member([Id,_],BigList),
		Playlist),
	open(FileName, write, Stream),
	writeln(Stream, Playlist),
	findall(Name,
		(
		member(X,Playlist),
		track(X,Name,_,_,_)
		),
		NameList),
	findall(ArtistNames,
		(
		member(X,Playlist),
		track(X,_,ArtistNames,_,_)
		),
		ArtistsList),	
	findall(Dist,
		member([_,Dist],BigList),
		DistList),	
	writeln(Stream, NameList),
	writeln(Stream, ArtistsList),	
	writeln(Stream, DistList), close(Stream).


excludeDisliked(List,DislikedGenres,Filtered):-
	findall(X,
		(
		member(X,List),
		getTrackGenre(X,Genres),
		member(D,DislikedGenres),
		member(G,Genres),
		sub_string(G,_,_,_,D)
		),
		List2),
	list_to_set(List2,Set),
	findall(A,
		(
		member(A,List),
		\+ member(A,Set)
		),
		List3),
	list_to_set(List3,Filtered).



%takes a List and returns its average as a float.
average(List, Result) :- average(List, 0, 0, Result).
average([], Sum, Count, Result) :- Result is Sum / Count.
average([H|T], Sum, Count, Result) :- 
	TempSum is Sum + H,
	TempCount is Count + 1,
	average(T, TempSum, TempCount, Result).


features([explicit-0, danceability-1, energy-1,
          key-0, loudness-0, mode-1, speechiness-1,
       	  acousticness-1, instrumentalness-1,
          liveness-1, valence-1, tempo-0, duration_ms-0,
          time_signature-0]).

filter_features(Features, Filtered) :- features(X), filter_features_rec(Features, X, Filtered).
filter_features_rec([], [], []).
filter_features_rec([FeatHead|FeatTail], [Head|Tail], FilteredFeatures) :-
    filter_features_rec(FeatTail, Tail, FilteredTail),
    _-Use = Head,
    (
        (Use is 1, FilteredFeatures = [FeatHead|FilteredTail]);
        (Use is 0,
            FilteredFeatures = FilteredTail
        )
    ).

%calculates features average
calculateAverageFeatures(List,AveragedFeatures):-
	findall(X,
		(member(Y,List),
		nth0(0,Y,X)
		),
		Feature0List),
	average(Feature0List,Feature0Average),
	findall(X,
		(member(Y,List),
		nth0(1,Y,X)
		),
		Feature1List),
	average(Feature1List,Feature1Average),
	findall(X,
		(member(Y,List),
		nth0(2,Y,X)
		),
		Feature2List),
	average(Feature2List,Feature2Average),
	findall(X,
		(member(Y,List),
		nth0(3,Y,X)
		),
		Feature3List),
	average(Feature3List,Feature3Average),
	findall(X,
		(member(Y,List),
		nth0(4,Y,X)
		),
		Feature4List),
	average(Feature4List,Feature4Average),
	findall(X,
		(member(Y,List),
		nth0(5,Y,X)
		),
		Feature5List),
	average(Feature5List,Feature5Average),
	findall(X,
		(member(Y,List),
		nth0(6,Y,X)
		),
		Feature6List),
	average(Feature6List,Feature6Average),
	findall(X,
		(member(Y,List),
		nth0(7,Y,X)
		),
		Feature7List),
	average(Feature7List,Feature7Average),
	append([Feature7Average],[],List7),
	append([Feature6Average],List7,List6),
	append([Feature5Average],List6,List5),
	append([Feature4Average],List5,List4),
	append([Feature3Average],List4,List3),
	append([Feature2Average],List3,List2),
	append([Feature1Average],List2,List1),
	append([Feature0Average],List1,AveragedFeatures).

%calculate euclidian distance between two features
distanceCalculator(Feature1,Feature2,Score):-
	[F10,F11,F12,F13,F14,F15,F16,F17] = Feature1,
	[F20,F21,F22,F23,F24,F25,F26,F27] = Feature2,
	Score is sqrt( (F10-F20)*(F10-F20) + (F11-F21)*(F11-F21) +  + (F12-F22)*(F12-F22) +
 (F13-F23)*(F13-F23) + (F14-F24)*(F14-F24) + (F15-F25)*(F15-F25) + (F16-F26)*(F16-F26) + (F17-F27)*(F17-F27)).
