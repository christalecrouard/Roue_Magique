function AnimBMP2C(NamIma,NbIm)

clc
clf




NbBaret = 1;

Puissance2NbParTour = 6;
NbParTour = 2^(Puissance2NbParTour);

Projc = ['.\Images\Image']



fileID = fopen([Projc,'.h'], 'w');
fprintf(fileID,'/*' );
dd=date;
fprintf(fileID,dd);
a=clock;
fprintf(fileID,' %d:%d:%d  */ \n\n',a(4),a(5),round(a(6)) );
 
fprintf(fileID,'#define Puissance2NbParTour %d\n',Puissance2NbParTour);
fprintf(fileID,'#define NbParTour %d\n',NbParTour);
fprintf(fileID,'#define NbImage %d\n',NbIm);
fprintf(fileID,'#define NbBaret %d\n',NbBaret);

fclose(fileID);

fileID = fopen([Projc,'.c'], 'w');
fprintf(fileID,'/*' );
dd=date;
fprintf(fileID,dd);
a=clock;
fprintf(fileID,' %d:%d:%d  */\n\n',a(4),a(5),round(a(6)) );
 
 fprintf(fileID,'#include "Image.h"\n');
 fprintf(fileID,'const unsigned char Rampe[NbImage][NbParTour][NbBaret][16*3]= \n');
 fprintf(fileID,'{\n');
 
 
for indIm = 1 : NbIm

    Namim = ['Images\',NamIma,num2str(indIm),'.bmp'];
    [YRGB] = imread(Namim);
    %size(YRGB)
    pause(0.5)
    image(YRGB)
    hold on
    B = YRGB(:,:,1);
    G = YRGB(:,:,2);
    R = YRGB(:,:,3);
    
    Si = size(YRGB);
    x0 = fix(Si(1)/2)+1
    y0 = fix(Si(2)/2)+1
    angle_init = 20*pi/180;
    
    fprintf(fileID,'/****** Image n°%d   */\n \t{\n',indIm);
    disp(sprintf('/****** Image n°%d ******',indIm))

    for indice = 1: NbParTour
     
        angle = (NbParTour - indice)*2*pi / NbParTour;      
        drawnow
        fprintf(fileID,'\t{\n');
        for Barret = 1 : NbBaret 
            fprintf(fileID,'\t\t{\n\t\t\t');
            for Led = 1 : 16  %6:-1 :1 
                
                Xn = max(1,y0 + round((Led+(Barret-1)*16) * cos(angle+angle_init)));
                Yn = max(1,x0 + round((Led+(Barret-1)*16) * sin(angle+angle_init)));
                fprintf(fileID,'%3d,%3d,%3d,    ',R(Xn,Yn),G(Xn,Yn),B(Xn,Yn));
                if (Led ==16)
                    c= text(Yn,Xn,'o');            
                end
                
                %disp(sprintf('%d = %3d,%3d,%3d,    ',indice,R(Xn,Yn),G(Xn,Yn),B(Xn,Yn)));
                %for i = 1 : 4
                %    subplot(220+i)
                %   
                %    c(i)= text(Yn,Xn,'*');
                %    set(c(i),'color',[0 .9 0])
                %end
                %delete(c)
            end
            
               
            fprintf(fileID,'\n\t\t},\n');
        end
        disp(sprintf('%d = %3d,%3d,%3d,    ',indice,R(Xn,Yn),G(Xn,Yn),B(Xn,Yn)));
        c= text(Yn,Xn,num2str(indice));
        set(c,'color',[0 .9 0])
                      
        fprintf(fileID,'\t},\n');
end

    fprintf(fileID,'\t},\n');
end
fprintf(fileID,'};\n');

fclose(fileID);
        

end

