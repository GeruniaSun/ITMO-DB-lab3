CREATE OR REPLACE FUNCTION person_id_trigger()
RETURNS TRIGGER AS $person_id_trigger$
BEGIN
    IF new.person_id IS NULL OR
        new.timestamp IS NULL OR
        new.location_id IS NULL
        THEN RAISE EXCEPTION 'Не введено значение одного из обязательных полей';
    END IF; -- выход по ошибке если не введено одно из обязательных значений
    new.health := LTRIM(RTRIM(new.health));
    IF new.health NOT IN ('good', 'dead', 'sick')
        THEN RAISE EXCEPTION 'Информация о здоровье должна быть представлена одной из трех строк: "good", "sick", "dead"';
    END IF; -- выход по ошибке при неправильном написании состояния здоровья
    IF new.location_id NOT IN (SELECT (id) FROM Location)
        THEN RAISE EXCEPTION 'Указан несуществующий номер локации'; 
    END IF; -- выход по ошибке при ссылке на несуществующее место
    IF new.person_id NOT IN (SELECT (id) FROM Person)
        THEN RAISE EXCEPTION 'Указан несуществующий номер человека'; 
    END IF; -- выход по ошибке при ссылке на несуществующего человека
    IF new.timestamp < 
        (SELECT (birth_date) FROM Person WHERE id = new.person_id)
        THEN RAISE EXCEPTION 'Указан момент во времени, когда данный человек еще не родился';
    END IF; -- выход по ошибке при ссылке на еще неродившенося человека

    RETURN new;
END;
$person_id_trigger$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER Person_condition_biur
BEFORE INSERT OR UPDATE ON Person_condition
FOR EACH ROW EXECUTE FUNCTION person_id_trigger();