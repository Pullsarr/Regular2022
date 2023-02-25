classdef landing_functions
    %LANDING_FUNCTIONS Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Property1
    end

    methods(Static)
        function obj=flight_mech(Config,Ciag,S,POS,Vod,gamma,mTOW)
            %% function to calculate reactions of aircraft
            %calculate dynamic thrust, drag coefficient, lift coefficient,
            %drag force, lift force, and reactions
            g=takeOFF_functions.g;
            Drag_k= takeOFF_functions.Drag_k;
            mi= takeOFF_functions.mi;
            rho=takeOFF_functions.rho;
            Q=mTOW*g;
            Ps=interp1(Ciag.data(:,1),Ciag.data(:,2),POS.Vx,"linear",'extrap')*g/5;
            Cz= interp1(Config.beta,Config.Cz,gamma-POS.beta,"linear","extrap");
            Cx= interp1(Config.beta,Config.Cx,gamma-POS.beta,"linear","extrap");
            Fy= (1/2)*rho*POS.V^2*Cz*S;
            Fx= (1/2)*rho*POS.V^2*Cx*S;
            if POS.Ly<=0
                Rx=Ps-mi*Q-(1/2)*rho*POS.Vx^2*S*0.0722*Drag_k*2;
                            Ps=0;
            Cz= interp1(Config.beta,Config.Cz,gamma-POS.beta,"linear","extrap");
            Cx= interp1(Config.beta,Config.Cx,gamma-POS.beta,"linear","extrap");
            Fy= (1/2)*rho*POS.V^2*Cz*S;
            Fx= (1/2)*rho*POS.V^2*Cx*S;
                Ry=0;
            else
                            Ps=interp1(Ciag.data(:,1),Ciag.data(:,2),POS.Vx,"linear",'extrap')*g/10;
            Cz= interp1(Config.beta,Config.Cz,gamma-POS.beta,"linear","extrap");
            Cx= interp1(Config.beta,Config.Cx,gamma-POS.beta,"linear","extrap");
            Fy= (1/2)*rho*POS.V^2*Cz*S;
            Fx= (1/2)*rho*POS.V^2*Cx*S;
                Rx=Ps*cos(gamma)-Fx*cos(POS.beta)*Drag_k-Fy*sin(POS.beta);
                Ry=Fy*cos(POS.beta)+Ps*sin(gamma)-Q-Fx*sin(POS.beta)*Drag_k;
            end
            ACC.ax=Rx/mTOW;
            ACC.ay=Ry/mTOW;
            obj=ACC;
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
        function obj=positioner(POS,deltai,ACC)
            %% positioner - calcualting the velocity and position of aircraft
            % calculate velocity, position and beta- angle off attack of
            % aircaft
            POSITION.Vx=POS.Vx+ACC.ax*deltai;
            POSITION.Vy=POS.Vy+ACC.ay*deltai;
            POSITION.Lx=POS.Lx+POS.Vx*deltai;
            POSITION.Ly=POS.Ly+POS.Vy*deltai;
            if POSITION.Ly<0
                POSITION.Ly=0;
            end
            POSITION.V=sqrt(POS.Vx^2+POS.Vy^2); %total velocity
            POSITION.beta=atan(POS.Vy/POS.Vx); %angle of attack
            obj=POSITION;
        end
        function obj=landing(Config,Ciag)
            S=Config.geo.S;
            deltai=0.001;
            g=9.81;
            gamma0=deg2rad(-5);
            gamma=gamma0;
            rho=1.16;
            mTOW=9.4;
            POS.V=0;
            POS.Vx=8;
            POS.Vy=-0.8;
            POS.Lx=0;
            POS.Ly=5;
            POS.beta=0;
            Q=mTOW*g;
            Vod=6;
            %% I phase- descent
            for i=deltai:deltai:60
                ACC=landing_functions.flight_mech(Config,Ciag,S,POS,Vod,gamma,mTOW);
                POS=landing_functions.positioner(POS,deltai,ACC);
                Config=landing_functions.tracker(Config,i,deltai,ACC,POS,gamma);
                if POS.Ly<1.5
                    i1=i;
                    break
                end
            end
            %% II phase
            for i=i1:deltai:60
                gamma=gamma0-gamma0*(i-i1)/6;
                ACC=landing_functions.flight_mech(Config,Ciag,S,POS,Vod,gamma,mTOW);
                POS=landing_functions.positioner(POS,deltai,ACC);
                Config=landing_functions.tracker(Config,i,deltai,ACC,POS,gamma);
                if gamma>=deg2rad(-2)
                    i2=i;
                    break
                end
            end
            %% III phase
            for i=i2:deltai:60
                ACC=landing_functions.flight_mech(Config,Ciag,S,POS,Vod,gamma,mTOW);
                POS=landing_functions.positioner(POS,deltai,ACC);
                Config=landing_functions.tracker(Config,i,deltai,ACC,POS,gamma);
                if POS.Vx<=0.1
                    break
                end
            end
            obj=Config;
        end
        function  obj= method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

