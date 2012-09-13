%% Funkce pro oznaceni seedu v obrazku
% [oSeeds, bSeeds, oSeedsIm, bSeedsIm] = markSeeds(fig, nghb, img)
% [oSeeds, bSeeds, oSeedsIm, bSeedsIm] = markSeeds(img)
% seedy - obsahuji souradnice: [radky; sloupce] - reprezentace jako v
% obrazku ci matici
% oSeeds, bSeeds - souřadnice bodu pozadi a popredi s rozsirenim o okoli
%     nghb
% oSeedsIm, bSeedsIm - obrazek bodu pozadi a popredi s okolim nghb.
%     Obsahuje stejnou informaci jako oSeeds, bSeeds, jen v jine forme

%TODO:
%   1) pri prilis rychlem tahu mysi se nestihnou zaznamenat vsechny
%      oznacene pixely (lineobj je aproximace linearnimi useky)
%       *) po oznaceni projet cely obrazek a ulozit vsechny souradnice
%          oznacenych pixelu (cervena nebo modra barva) - zdlouhave
%   2) zamezit moznosti nulove souradnice
%   3) tloustka cary zpusobi jenom zvyrazneni - neovlivni vyber pixelu z
%      okoli cary
%       *) viz 1)*)
%       *) ponechat zatim vyber jenom tloustky 1

function [oSeeds, bSeeds, oSeedsIm, bSeedsIm] = markSeeds(varargin)
% fig, nghb, img
% edit - mjirik
% img = [];
fig = [];
img = [];
nghb = 3;

% osetreni zda je prvni vstup obrazek, nebo cislo figury
if (nargin < 1)
  fig = figure;
  img = imread('cameraman.tif');
  imshow(img);
%   nghb = 3;
else
    nd = ndims (varargin{1});
    % ndims dava nejmene dva
    if nd == 2 && numel(varargin{1}) == 1
        nd = 1;
    end
    if nd == 1
        % je to cislo figury
        fig = varargin{1};
    elseif nd == 2
        % je to obrazek
        fig = figure;
        img = varargin{1};
        imshow(img);
    else 
        error('Prvnim parametrem je bud cislo figury, nebo obrazek');
    end
end
if (nargin == 1)
    % jeden parametr
%     nghb=3;

end
if(nargin == 2)
    nghb = varargin{2};
    %nevim jak se dostat k puvodnimu obrazku, nasel jsem dve moznosti,
    %kazda obcas funguje
   img = get(get(fig,'CurrentObject'),'CData');
    
   if (size (img,1) == 0)
     img = get(get(get(fig,'Children'),'Children'),'CData');
   end
   
end
if nargin == 3
    fig = varargin{1};
    nghb = varargin{2};
    img = varargin{3};
end

%end edit - mjirik
oSeeds = [];
bSeeds = [];
lineobj = [];
w = nghb*2;
hold on

%tohle vylouska z fig puvodni obrazek
% img = get(get(fig,'CurrentObject'),'CData');
%img = get(get(get(fig,'Children'),'Children'),'CData');


startClick(fig,w);
set(fig,'Pointer','crosshair','WindowButtonDownFcn',@wbdcb, 'KeyPressFcn',@kpcb);

key = '';

% while(~strcmp(key,'return'))
%     waitforbuttonpress
% end
waitfor(fig,'KeyPressFcn','')

[oSeeds, bSeeds, oSeedsIm, bSeedsIm] = addNeighbourhood(img, nghb, oSeeds, bSeeds);

%    set(fig,'WindowButtonMotionFcn','');
%    set(fig,'WindowButtonDownFcn','');
%    set(fig,'KeyPressFcn','');
%    set(fig,'Pointer','arrow');

    function wbdcb(varargin)
        if(strcmp(get(fig,'WindowButtonMotionFcn'),''))%zadny callback neprirazen => klik = zacatek znaceni
            startClick(fig,w);
            set(fig,'WindowButtonMotionFcn',@wbmcb);
        else %callback je prirazen => klik = konec znaceni
            points = get(lineobj,'ydata');
            points(2,:) = get(lineobj,'xdata');
            % edit -mjirik - kontrola nezapornosti souradnic
            set(fig,'WindowButtonMotionFcn','');
            
            pts = [];
            for i=1:size(points,2)
              if (points (:,i) > 0)
                pts = [pts points(:,i)];
              end
            end
            % end edit -mjirik
            if(strcmp(get(fig,'SelectionType'),'normal'))%jedna se o seedy objektu
                oSeeds(:,size(oSeeds,2)+1:size(oSeeds,2)+size(points,2)) = points;
                oSeeds = round(oSeeds);
            else %jedna se o seedy pozadi
                bSeeds(:,size(bSeeds,2)+1:size(bSeeds,2)+size(points,2)) = points;
                bSeeds = round(bSeeds);
            end
            
            lineobj = [];
        end
    end

    function wbmcb(varargin)
        %kresleni cary tahem mysi
        oznX = get(lineobj,'xdata');
        oznY = get(lineobj,'ydata');
        cp = get(get(fig,'CurrentAxes'),'CurrentPoint');
        %vytvareni objektu krivky
        set(lineobj,'xdata',[oznX,cp(1,1)],'ydata',[oznY,cp(1,2)]);
        drawnow;
    end

    function kpcb(src,evnt)
        key = evnt.Key;
        if(strcmp(key,'return'))
           oSeeds = round(oSeeds);
           bSeeds = round(bSeeds);
           set(fig,'WindowButtonMotionFcn','');
           set(fig,'WindowButtonDownFcn','');
           set(fig,'KeyPressFcn','');
           set(fig,'Pointer','arrow');
        end
    end

     % Funkce vytvori zahajujici klik
    function startClick(fig,w)
        
        cp = get(get(fig,'CurrentAxes'),'CurrentPoint');
        xs = cp(1,1);
        ys = cp(1,2);
        if(strcmp(get(fig,'SelectionType'),'normal')) %stisk leveho mysitka
            c = 'r';
        else %stisk praveho mysitka
            c = 'b';
        end
        lineobj = line(xs,ys,'tag','line','LineWidth',w,'Color',c);
    end
  
  

  

% Funkce prida k bodum oSeeds a bSeeds jeste body z jejich okoli
% fig - figure a
% oSeeds, bSeeds - souřadnice bodu pozadi a popredi s rozsirenim o okoli
% oSeedsIm, bSeedsIm - obrazek bodu pozadi a popredi s okolim
  function  [oSeeds, bSeeds, oSeedsIm, bSeedsIm] = addNeighbourhood (img, nghb, oSeeds, bSeeds)
      
      %tohle vylouska z fig puvodni obrazek
%       img = get(get(fig,'CurrentObject'),'CData');
      imsiz  = size(img);
      
      % chci udelat obrzek kde bude jednicka tam kde je kliknuto
      % vychozi obrazek kde jsou jen nuly
      oSeedsIm = zeros(imsiz(1:2));
      bSeedsIm = zeros(imsiz(1:2));
      
      
      %prevod souradnic na indexy
      if size (oSeeds,1) > 1
        oInd = sub2ind(imsiz(1:2),oSeeds(1,:),oSeeds(2,:));
      else
          oInd = [];
      end
      if size (bSeeds,1) > 1
        bInd = sub2ind(imsiz(1:2),bSeeds(1,:),bSeeds(2,:));
      else 
          bInd = [];
      end
      
      % nastavim jednicky
      oSeedsIm(oInd) = 1;
      bSeedsIm(bInd) = 1;
      
      %obraz kde je vzdalenost od pixelu s jednickou
      oSeedsIm = bwdist(oSeedsIm);
      bSeedsIm = bwdist(bSeedsIm);
      
      %binarni obraz
      oSeedsIm = oSeedsIm < (nghb*0.5);
      bSeedsIm = bSeedsIm < (nghb*0.5);
      
      
      
      oSeeds = [];
      bSeeds = [];
      for i = 1:imsiz(1)
        for j = 1:imsiz(2)
          if oSeedsIm(i,j) == 1
            oSeeds = cat(2,oSeeds, [i;j]);
          end
          if bSeedsIm(i,j) == 1
            bSeeds = cat(2,bSeeds ,[ i;j]);
          end
          
        end
      end

      
  end
  
    

end
