CREATE OR REPLACE FUNCTION aktualizuj_po_zakonczeniu_wypozyczenia()
RETURNS TRIGGER AS $$
BEGIN

    UPDATE public.samochody
    SET dostepnosc = TRUE
    WHERE samochod_id = NEW.samochod_id;
    
    DECLARE
        v_dni INTEGER;
        v_kilometry INTEGER;
        v_koszt_dzien NUMERIC(15, 2);
        v_koszt_kilometr NUMERIC(15, 2);
        v_kwota_calkowita NUMERIC(10, 2);
        v_id_potwierdzenia INTEGER;
        v_platnosc_id INTEGER;
    BEGIN
        v_dni := NEW.koniec_wypozyczenia - NEW.start_wypozyczenia;
        
        v_kilometry := NEW.przebieg_koniec - NEW.przebieg_start;
        
        SELECT k.koszt_dzien, k.koszt_kilometr
        INTO v_koszt_dzien, v_koszt_kilometr
        FROM public.samochody s
        JOIN public.koszt k ON s.koszt_id = k.koszt_id
        WHERE s.samochod_id = NEW.samochod_id;
        
        v_kwota_calkowita := (v_dni * v_koszt_dzien) + (v_kilometry * v_koszt_kilometr);
        
        v_id_potwierdzenia := floor(random() * 900000) + 100000;
        
        INSERT INTO public.platnosc (id_potwierdzenia, metoda_platnosci, kwota)
        VALUES (v_id_potwierdzenia, 'Do zdefiniowania', v_kwota_calkowita)
        RETURNING platnosc_id INTO v_platnosc_id;
        
        
        UPDATE public.wypozyczenia
        SET platnosc_id = v_platnosc_id
        WHERE wypozyczenie_id = NEW.wypozyczenie_id;
    END;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_po_zakonczeniu_wypozyczenia
AFTER UPDATE OF przebieg_koniec
ON public.wypozyczenia
FOR EACH ROW
WHEN (OLD.przebieg_koniec IS NULL AND NEW.przebieg_koniec IS NOT NULL)
EXECUTE FUNCTION aktualizuj_po_zakonczeniu_wypozyczenia();

CREATE OR REPLACE PROCEDURE wypozycz_samochod(
    p_id_klienta INTEGER,
    p_samochod_id INTEGER,
    p_id_pracownika INTEGER,
    p_start_wypozyczenia DATE,
    p_koniec_wypozyczenia DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_przebieg_start INTEGER;
    v_wypozyczenie_id INTEGER;
    v_dostepnosc BOOLEAN;
BEGIN
    SELECT dostepnosc INTO v_dostepnosc
    FROM public.samochody
    WHERE samochod_id = p_samochod_id;
    
    IF v_dostepnosc = FALSE THEN
        RAISE EXCEPTION 'Samochód o ID % nie jest dostępny do wypożyczenia.', p_samochod_id;
    END IF;
    
    SELECT COALESCE(
        (SELECT przebieg_koniec 
         FROM public.wypozyczenia 
         WHERE samochod_id = p_samochod_id 
         ORDER BY koniec_wypozyczenia DESC 
         LIMIT 1),
        0) INTO v_przebieg_start;
    
    SELECT COALESCE(MAX(wypozyczenie_id), 0) + 1 INTO v_wypozyczenie_id
    FROM public.wypozyczenia;
    
    INSERT INTO public.wypozyczenia (
        wypozyczenie_id,
        id_klienta,
        samochod_id,
        id_pracownika,
        start_wypozyczenia,
        koniec_wypozyczenia,
        przebieg_start,
        przebieg_koniec
    ) VALUES (
        v_wypozyczenie_id,
        p_id_klienta,
        p_samochod_id,
        p_id_pracownika,
        p_start_wypozyczenia,
        p_koniec_wypozyczenia,
        v_przebieg_start,
        NULL
    );
    
    UPDATE public.samochody
    SET dostepnosc = FALSE
    WHERE samochod_id = p_samochod_id;
    
    RAISE NOTICE 'Utworzono wypożyczenie o ID: %', v_wypozyczenie_id;
END;
$$;

CREATE OR REPLACE PROCEDURE zakoncz_wypozyczenie(
    p_wypozyczenie_id INTEGER,
    p_przebieg_koniec INTEGER,
    p_metoda_platnosci VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_samochod_id INTEGER;
    v_data_start DATE;
    v_data_koniec DATE;
    v_przebieg_start INTEGER;
    v_koszt_id INTEGER;
    v_koszt_dzien NUMERIC(15, 2);
    v_koszt_kilometr NUMERIC(15, 2);
    v_dni INTEGER;
    v_kilometry INTEGER;
    v_kwota NUMERIC(10, 2);
    v_id_potwierdzenia INTEGER;
    v_platnosc_id INTEGER;
BEGIN
    SELECT samochod_id, start_wypozyczenia, koniec_wypozyczenia, przebieg_start
    INTO v_samochod_id, v_data_start, v_data_koniec, v_przebieg_start
    FROM public.wypozyczenia
    WHERE wypozyczenie_id = p_wypozyczenie_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Wypożyczenie o ID % nie istnieje.', p_wypozyczenie_id;
    END IF;
    
    IF p_przebieg_koniec <= v_przebieg_start THEN
        RAISE EXCEPTION 'Przebieg końcowy (%) musi być większy niż przebieg początkowy (%).', 
                        p_przebieg_koniec, v_przebieg_start;
    END IF;
    
    SELECT s.koszt_id INTO v_koszt_id
    FROM public.samochody s
    WHERE s.samochod_id = v_samochod_id;
    
    SELECT koszt_dzien, koszt_kilometr
    INTO v_koszt_dzien, v_koszt_kilometr
    FROM public.koszt
    WHERE koszt_id = v_koszt_id;
    
    v_dni := v_data_koniec - v_data_start;
    IF v_dni < 1 THEN
        v_dni := 1; 
    END IF;
    
    v_kilometry := p_przebieg_koniec - v_przebieg_start;
    
    v_kwota := (v_dni * v_koszt_dzien) + (v_kilometry * v_koszt_kilometr);
    
    v_id_potwierdzenia := floor(random() * 900000) + 100000;
    
    INSERT INTO public.platnosc (id_potwierdzenia, metoda_platnosci, kwota)
    VALUES (v_id_potwierdzenia, p_metoda_platnosci, v_kwota)
    RETURNING platnosc_id INTO v_platnosc_id;
    
    UPDATE public.wypozyczenia
    SET przebieg_koniec = p_przebieg_koniec,
        platnosc_id = v_platnosc_id
    WHERE wypozyczenie_id = p_wypozyczenie_id;
    
    UPDATE public.samochody
    SET dostepnosc = TRUE
    WHERE samochod_id = v_samochod_id;
    
    RAISE NOTICE 'Zakończono wypożyczenie o ID: %. Kwota do zapłaty: %', p_wypozyczenie_id, v_kwota;
END;
$$;
