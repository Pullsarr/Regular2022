classdef takeOFF_functions
    %% Description of the functions
    %% detailed description is placed into the function
    %  naming_data - function to rename, and delete useless information
    %  from input
    %
    %  geo_data - inserting infromation about geoemtric from file
    %
    %  minimum_RX - function to find best wedge angle of airfoil
    %
    % flight mech - function to calculate reactions of aircraft
    %
    %positioner - calcualting the velocity and position of aircraft depends
    % using numeric integrals
    %
    %tracker- function to save up all the date about acceleration,
    %velocity, postions and angles of aircraft
    %
    % start_anal- analyse of all 6 phases of start
    %
    % pathing- function to track the aircraft with maxPayload
    %
    % final_points - calculate points for the aircraft as per SAE 2023
    % competition
    %
    % plotter- function to plot all the information needed into
    % documentation

    properties (Constant)
        g=9.81; %standard gravity
        rho=1.16; %air density in texas
        deltai=0.001; %iteration step
        mi=0.04; %rolling resistance coefficient
        Drag_k=1.3; %drag imaginary coefficient
    end

    methods (Static)
        function obj = naming_data(Config,name)
            %% naming_data - function to rename, and delete useless information
            %function read the file then delete useless information and
            %create extra names in main structures for Cz, Cx, and name
            names=Config.textdata(5,:);
            Config= rmfield(Config,"textdata");
            Config= rmfield(Config, "colheaders");
            Config.dataT= array2table(Config.data,"VariableNames",names);
            Config.beta=deg2rad(Config.data(:,1));
            Config.Cz=Config.data(:,3);
            Config.Cx=Config.data(:,6);
            Config.name=name;
            obj=Config;
        end
        function obj = geo_data(Config,geometric_data,name)
            %% geo_data - inserting infromation about geoemtric from file
            % function use subfunction find to go throught excel with
            % geometric informations and find wingspan, aspect ration, wing
            % area, empty mass and medium aerodynamic chord
            [row, col] = find(contains(geometric_data.textdata,name),1,"first");
            Config.geo.B=geometric_data.data(1,col-1);
            Config.geo.AR=geometric_data.data(2,col-1);
            Config.geo.S=geometric_data.data(3,col-1);
            Config.geo.Mo=geometric_data.data(4,col-1);
            Config.geo.lambda= geometric_data.data(5,col-1);
            Config.geo.MAC= geometric_data.data(6,col-1);
            obj= Config;
        end
        function obj = minimum_Rx(Config)
            %% minimum_RX - function to find best wedge angle of airfoil
            %ocalculate optimal coefficient k for rolling resistance
            Config.min.k=100;
            for i=1:height(Config.data)
                k= Config.Cx(i)-Config.Cz(i)*takeOFF_functions.mi; %Cx-Cz*mi
                if k<Config.min.k
                    Config.min.beta=Config.beta(i);
                    Config.min.k=k;
                    Config.min.Cz=Config.Cz(i);
                    Config.min.Cx=Config.Cx(i);
                end
            end
            obj=Config;
        end
        function obj=flight_mech(Config,Ciag,S,POS,Vod,gamma,mTOW)
            %% function to calculate reactions of aircraft
            %calculate dynamic thrust, drag coefficient, lift coefficient,
            %drag force, lift force, and reactions
            g=takeOFF_functions.g;
            Drag_k= takeOFF_functions.Drag_k;
            mi= takeOFF_functions.mi;
            rho=takeOFF_functions.rho;
            Q=mTOW;
            Ps=interp1(Ciag.data(:,1),Ciag.data(:,2),POS.Vx,"linear",'extrap')*g;
            Cz= interp1(Config.beta,Config.Cz,gamma-POS.beta+Config.min.beta,"linear","extrap");
            Cx= interp1(Config.beta,Config.Cx,gamma-POS.beta+Config.min.beta,"linear","extrap");
            Fy= (1/2)*rho*POS.V^2*Cz*S;
            Fx= (1/2)*rho*POS.V^2*Cx*S;
            if POS.V<Vod
                Rx=Ps-mi*Q-(1/2)*rho*POS.Vx^2*S*Config.min.k*Drag_k;
                Ry=0;
            else
                Rx=Ps*cos(gamma)-Fx*cos(POS.beta)*Drag_k-Fy*sin(POS.beta);
                Ry=Fy*cos(POS.beta)+Ps*sin(gamma)-Q-Fx*sin(POS.beta)*Drag_k;
            end
            ACC.ax=Rx/mTOW;
            ACC.ay=Ry/mTOW;
            obj=ACC;
        end
        function obj=positioner(POS,deltai,ACC)
            %% positioner - calcualting the velocity and position of aircraft
            % calculate velocity, position and beta- angle off attack of
            % aircaft
            POSITION.Vx=POS.Vx+ACC.ax*deltai;
            POSITION.Vy=POS.Vy+ACC.ay*deltai;
            POSITION.Lx=POS.Lx+POS.Vx*deltai;
            POSITION.Ly=POS.Ly+POS.Vy*deltai;
            POSITION.V=sqrt(POS.Vx^2+POS.Vy^2); %total velocity
            POSITION.beta=atan(POS.Vy/POS.Vx); %angle of attack
            obj=POSITION;
        end
        function obj=tracker(Config,i,deltai,ACC,POS,gamma)
            %% tracker- function to save up all the date
            %saving up acceleration, velocity, postion, and angles
            Config.path(int32(i/deltai),1)=i;
            Config.path(int32(i/deltai),2)=ACC.ax;
            Config.path(int32(i/deltai),3)=ACC.ay;
            Config.path(int32(i/deltai),4)=POS.V;
            Config.path(int32(i/deltai),5)=POS.Vx;
            Config.path(int32(i/deltai),6)=POS.Vy;
            Config.path(int32(i/deltai),7)=POS.Lx;
            Config.path(int32(i/deltai),8)=POS.Ly;
            Config.path(int32(i/deltai),9)=rad2deg(POS.beta);
            Config.path(int32(i/deltai),10)=rad2deg(gamma);
            obj=Config;
        end
        function obj= start_anal(Config,Ciag,timeW,Lstart,MFV, MCV, Rot1_angle,Rot2_angle, Rot1_time, Rot1B_time, Rot2_time,Hmin,Lmax)
            %% analyse of all 6 phases of start
            rho=takeOFF_functions.rho;
            g=takeOFF_functions.g;
            deltai=takeOFF_functions.deltai;
            Config.PAYLOAD=0;
            S=Config.geo.S;
            for PAYLOAD=5:0.2:100
                mTOW=PAYLOAD+Config.geo.Mo;
                POS.V=0;
                POS.Vx=0;
                POS.Vy=0;
                POS.Lx=0;
                POS.Ly=0;
                POS.beta=0;
                Q=mTOW*g;
                gamma=0;
                % calculate take-off velocity as 1.2 velocity of force
                % balance
                Vod_min=1.2*sqrt(2*Q/(rho*S*Config.min.Cz));
                Cz_od= interp1(Config.beta,Config.Cz,deg2rad(Rot1_angle),"linear","extrap");
                Vod=1.2*sqrt(2*Q/(rho*S*Cz_od));
                %% I phase- run up
                % phase is end when aircraft pass the Lstart distance
                for i=deltai:deltai:timeW
                    ACC=takeOFF_functions.flight_mech(Config,Ciag,S,POS,Vod,gamma,mTOW);
                    POS=takeOFF_functions.positioner(POS,deltai,ACC);
                    if (POS.Lx>Lstart) || (POS.V>Vod_min)
                        i1=i;
                        break
                    end
                end
                %% II phase- ground rotation
                % aircraft is rotating to Rot1_angle in Rot1_time
                %gamma- pitch angle of aircraft to ground
                % if after ground rotation aircraft is still on the ground
                for i=i1:deltai:timeW
                    ACC=takeOFF_functions.flight_mech(Config,Ciag,S,POS,Vod,gamma,mTOW);
                    POS=takeOFF_functions.positioner(POS,deltai,ACC);
                    if i<=(i1+Rot1_time)
                        gamma=((i-i1)/Rot1_time)*deg2rad(Rot1_angle);
                    else
                        i2=i;
                        break
                    end
                end
                if (POS.Ly==0)
                    Config.Erorr= 'R22 could not take off after ground rotation';
                    break
                end
                %% III faza- alignment
                % aircraft in this phase is alignment to be parallel to the
                % gorund
                % after this phase aircraft should be at lest 0.5m
                % over ground
                for i=i2:deltai:timeW
                    ACC=takeOFF_functions.flight_mech(Config,Ciag,S,POS,Vod,gamma,mTOW);
                    POS=takeOFF_functions.positioner(POS,deltai,ACC);
                    if i<=(i2+Rot1B_time)
                        gamma=deg2rad(Rot1_angle)-((i-i2)/Rot1B_time)*deg2rad(Rot1_angle);
                    else
                        i3=i;
                        break
                    end
                end
                if (POS.Ly<0.5)
                    Config.Erorr= 'R22 can not keep 0.5 after alignment phase';
                    break
                end
                %% IV faza- speed up
                % in this phase aircraft is pure speeding up
                % phase is going to end if the R22 exceede MFV or can nto
                % accelerate more
                for i=i3:deltai:timeW
                    ACC=takeOFF_functions.flight_mech(Config,Ciag,S,POS,Vod,gamma,mTOW);
                    POS=takeOFF_functions.positioner(POS,deltai,ACC);
                    if (POS.Vx>MFV) || (ACC.ax<0.01)
                        i4=i;
                        L4=POS.Lx;
                        break
                    end
                end
                if (ACC.ax<0.01)
                    Config.Erorr= 'R22 can not achieve MFV during speed up';
                    break
                end
                %% V faza- air rotation
                % in this phase R22 rotate in the air to keep climbing
                % pitch angle
                %phase break if Vx<MFV
                for i=i4:deltai:timeW
                    ACC=takeOFF_functions.flight_mech(Config,Ciag,S,POS,Vod,gamma,mTOW);
                    POS=takeOFF_functions.positioner(POS,deltai,ACC);
                    if i<=(i4+Rot2_time)
                        gamma=((i-i4)/Rot2_time)*deg2rad(Rot2_angle);
                    else
                        i5=i;
                        break
                    end
                end
                if (POS.Vx<MFV)
                    Config.Erorr= 'R22 could not maintain speed during air rotation';
                    break
                end
                %% VI faza- climbing
                % pure climbing, phase gona break if aircraft exceede
                % climbing distance, Vx<MFV, or Vy<MCV
                for i=i5:deltai:timeW
                    ACC=takeOFF_functions.flight_mech(Config,Ciag,S,POS,Vod,gamma,mTOW);
                    POS=takeOFF_functions.positioner(POS,deltai,ACC);
                    if (POS.Ly>Hmin) || (POS.Lx>Lmax+L4) || (POS.Vx<MFV) || (POS.Vy<MCV)
                        break
                    end
                end
                if (POS.Ly>Hmin)
                    Config.PAYLOAD=PAYLOAD;
                    Config.MTOW=mTOW;
                elseif (POS.Lx>Lmax+L4)
                    Config.Erorr= 'R22 could not climb in limiting distance';
                    break
                elseif (POS.Vx<MFV)
                    Config.Erorr= 'R22 could not maintain speed during climb';
                    break
                elseif (POS.Vy<MCV)
                    Config.Erorr='R22 could not climb at MCV';
                    break
                end
            end
            obj=Config;
        end
        function obj = pathing(Config,Ciag,timeW,Lstart,MFV, MCV,Rot1_angle,Rot2_angle, Rot1_time, Rot1B_time, Rot2_time,Hmin,Lmax)
            rho=takeOFF_functions.rho;
            g=takeOFF_functions.g;
            deltai=takeOFF_functions.deltai;
            S=Config.geo.S;
            mTOW=Config.MTOW;
            POS.V=0;
            POS.Vx=0;
            POS.Vy=0;
            POS.Lx=0;
            POS.Ly=0;
            POS.beta=0;
            Q=mTOW*g;
            gamma=0;
            Cz_od= interp1(Config.beta,Config.Cz,deg2rad(Rot1_angle),"linear","extrap");
            Vod=1.2*sqrt(2*Q/(rho*S*Cz_od));
            %% I phase- run up
            for i=deltai:deltai:timeW
                ACC=takeOFF_functions.flight_mech(Config,Ciag,S,POS,Vod,gamma,mTOW);
                POS=takeOFF_functions.positioner(POS,deltai,ACC);
                Config=takeOFF_functions.tracker(Config,i,deltai,ACC,POS,gamma);
                if (POS.Lx>Lstart)
                    i1=i;
                    break
                end
            end
            %% II phase- ground rotation
            for i=i1:deltai:timeW
                ACC=takeOFF_functions.flight_mech(Config,Ciag,S,POS,Vod,gamma,mTOW);
                POS=takeOFF_functions.positioner(POS,deltai,ACC);
                Config=takeOFF_functions.tracker(Config,i,deltai,ACC,POS,gamma);
                if i<=(i1+Rot1_time)
                    gamma=((i-i1)/Rot1_time)*deg2rad(Rot1_angle);
                else
                    i2=i;
                    break
                end
            end
            %% III faza- alignment
            for i=i2:deltai:timeW
                ACC=takeOFF_functions.flight_mech(Config,Ciag,S,POS,Vod,gamma,mTOW);
                POS=takeOFF_functions.positioner(POS,deltai,ACC);
                Config=takeOFF_functions.tracker(Config,i,deltai,ACC,POS,gamma);
                if i<=(i2+Rot1B_time)
                    gamma=deg2rad(Rot1_angle)-((i-i2)/Rot1B_time)*deg2rad(Rot1_angle);
                else
                    i3=i;
                    break
                end
            end
            %% IV faza- speed up
            for i=i3:deltai:timeW
                ACC=takeOFF_functions.flight_mech(Config,Ciag,S,POS,Vod,gamma,mTOW);
                POS=takeOFF_functions.positioner(POS,deltai,ACC);
                Config=takeOFF_functions.tracker(Config,i,deltai,ACC,POS,gamma);
                if (POS.Vx>MFV) || (ACC.ax<0.01)
                    i4=i;
                    L4=POS.Lx;
                    break
                end
            end
            %% V faza- air rotation
            for i=i4:deltai:timeW
                ACC=takeOFF_functions.flight_mech(Config,Ciag,S,POS,Vod,gamma,mTOW);
                POS=takeOFF_functions.positioner(POS,deltai,ACC);
                Config=takeOFF_functions.tracker(Config,i,deltai,ACC,POS,gamma);
                if i<=(i4+Rot2_time)
                    gamma=((i-i4)/Rot2_time)*deg2rad(Rot2_angle);
                else
                    i5=i;
                    break
                end
            end
            %% VI faza- climbing
            for i=i5:deltai:timeW
                ACC=takeOFF_functions.flight_mech(Config,Ciag,S,POS,Vod,gamma,mTOW);
                POS=takeOFF_functions.positioner(POS,deltai,ACC);
                Config=takeOFF_functions.tracker(Config,i,deltai,ACC,POS,gamma);
                if (POS.Ly>Hmin) || (POS.Lx>Lmax+L4) || (POS.Vx<MFV) || (POS.Vy<MCV)
                    break
                end
            end
            VarNames={'time','ax','ay','V','Vx','w','Lx','Ly','beta','gamma'};
            Config.pathT=array2table(Config.path,"VariableNames",VarNames);
            obj=Config;
        end
        function obj = final_points(Config)
            Config.WS=2^(1+0.0833333*Config.geo.B/5);
            Config.FS=Config.PAYLOAD(1)*2.20462/2;
            Config.FFS= 3*Config.FS+Config.WS;
            obj=Config;
        end
        function obj= sorting(a,b)
            c= a*takeOFF_functions.g+b;
            obj=c;
        end
    end
end




